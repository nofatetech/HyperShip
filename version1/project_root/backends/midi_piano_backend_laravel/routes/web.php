<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PianoController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/test-websocket', function () {
    return view('test-websocket');
});
