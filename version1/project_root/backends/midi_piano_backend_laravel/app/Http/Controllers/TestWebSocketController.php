<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TestWebSocketController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $token = $user->createToken('websocket-token')->plainTextToken;

        return view('test-websocket', [
            'token' => $token
        ]);
    }
} 