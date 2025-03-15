<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Groups extends Model
{
    use HasFactory;

    protected $table = 'groups';

    protected $fillable = ['id','franchise_id', 'instructor_id', 'cw_uid', 'group_name',
        'start_date', 'start_time', 'end_time', 'payer_id',
        'price_type_id', 'program_id', 'pos_id',
        'total_revenue_share', 'your_revenue_share'];
}
