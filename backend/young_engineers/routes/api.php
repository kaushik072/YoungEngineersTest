<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AttendanceController;
 
Route::post('/fatch-attendance', [AttendanceController::class, 'getAllAttendance']);
    