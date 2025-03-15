import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:young_engineers/app/modules/utils/api_endpoints.dart';

class ApiClient {
  final Dio _dio = Dio();
  final String _baseUrl = ApiEndpoints.baseUrl;

  ApiClient() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    if (!kReleaseMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      _validateResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      _validateResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  void _validateResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException(
        response.data['message'] ?? 'Unauthorized access',
      );
    }

    if (response.statusCode == 403) {
      throw ForbiddenException(response.data['message'] ?? 'Forbidden access');
    }

    if (response.statusCode == 404) {
      throw NotFoundException(response.data['message'] ?? 'Resource not found');
    }

    throw ApiException(
      response.data['message'] ?? 'Unknown error occurred',
      response.statusCode,
    );
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Connection timed out');
        case DioExceptionType.badResponse:
          return ApiException(
            'Server error: ${error.response?.statusCode}',
            error.response?.statusCode,
          );
        case DioExceptionType.cancel:
          return RequestCancelledException('Request cancelled');
        case DioExceptionType.connectionError:
          return NetworkException('No internet connection');
        default:
          return NetworkException('Network error occurred');
      }
    }
    return UnknownException('Something went wrong');
  }
}

// Custom Exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message, null);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message, null);
}

class RequestCancelledException extends ApiException {
  RequestCancelledException(String message) : super(message, null);
}

class UnknownException extends ApiException {
  UnknownException(String message) : super(message, null);
}
