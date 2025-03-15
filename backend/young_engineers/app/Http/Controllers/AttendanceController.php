<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Groups;

class AttendanceController extends Controller
{
    public function getAllAttendance(Request $request)
    {
        $filters = $request->json()->all();

         $mainTable = 'dummy_attendance'; 

        $query = DB::table($mainTable);

         if (!empty($filters)) {
            foreach ($filters as $column => $value) {
                if ($column === 'groupIds' && is_numeric($value)) {
                    // Use where for a single group_id
                    $query->where('group_id', $value);
                } elseif ($column === 'pos_id' && is_numeric($value)) {
                    // Use where for a single pos_id
                    $query->where('pos_id', $value);
                } elseif ($column === 'start_date' && isset($filters['end_date'])) {
                    // Ensure both start_date and end_date exist before applying the filter
                    $query->whereBetween('date', [$filters['start_date'], $filters['end_date']]);
                } elseif (DB::getSchemaBuilder()->hasColumn($mainTable, $column)) {
                    // Apply other dynamic filters
                    $query->where($column, $value);
                }
            }
        }
         $query->orderBy('created_at', 'desc');
        $data = $query->get();
         return response()->json([
            'status' => true,
            'message' => 'Attendance Fetch Successfully!',
            'data' => $data
        ], 200);
    }
}

