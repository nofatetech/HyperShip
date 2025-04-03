<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PianoController;
use App\Http\Controllers\TestWebSocketController;

Route::get('/', function () {
    return view('welcome');
});

Route::middleware(['auth'])->group(function () {
    Route::get('/test-websocket', [TestWebSocketController::class, 'index']);
});
