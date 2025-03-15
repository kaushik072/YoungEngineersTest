import 'package:get/get.dart';
import '../../../data/api/api_client.dart';
import '../../../data/repository/attendance_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register API client
    Get.put(ApiClient());

    // Register repository with API client dependency
    Get.put(AttendanceRepository(Get.find<ApiClient>()));

    // Register controller with repository dependency
    Get.put(HomeController(Get.find<AttendanceRepository>()));
  }
}
