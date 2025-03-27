<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PianoController extends Controller
{
    public function play(Request $request)
    {
        $data = $request->validate([
            'note' => 'required|integer|min:0|max:127',
            'velocity' => 'required|integer|min:0|max:127',
            'timestamp' => 'required|numeric'
        ]);

        // Log the received data
        Log::info('Received piano note', $data);

        // Send to WebSocket server
        $this->sendToWebSocket($data);

        return response()->json([
            'message' => 'Note received and broadcasted',
            'data' => $data
        ]);
    }

    private function sendToWebSocket($data)
    {
        $client = stream_socket_client('tcp://127.0.0.1:6001', $errno, $errstr, 30);
        
        if (!$client) {
            Log::error("Failed to connect to WebSocket server: $errstr ($errno)");
            return;
        }

        // Create WebSocket frame
        $frame = $this->createFrame(json_encode($data));
        
        // Send the frame
        fwrite($client, $frame);
        
        fclose($client);
    }

    private function createFrame($message)
    {
        $frame = chr(0x81); // Text frame
        $length = strlen($message);
        
        if ($length <= 125) {
            $frame .= chr($length);
        } elseif ($length <= 65535) {
            $frame .= chr(126) . pack('n', $length);
        } else {
            $frame .= chr(127) . pack('J', $length);
        }
        
        return $frame . $message;
    }
}
