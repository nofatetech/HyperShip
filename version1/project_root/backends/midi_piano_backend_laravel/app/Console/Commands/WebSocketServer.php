<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class WebSocketServer extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'websocket:serve {--max-connections=100}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Start the WebSocket server';

    protected $clients = [];
    protected $maxConnections;
    protected $read = [];
    protected $write = [];
    protected $except = [];

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->maxConnections = $this->option('max-connections');
        $this->info('Starting WebSocket server...');
        $this->info("Maximum connections allowed: {$this->maxConnections}");
        
        // Create server socket
        $context = stream_context_create();
        $server = stream_socket_server('tcp://127.0.0.1:6001', $errno, $errstr, STREAM_SERVER_BIND | STREAM_SERVER_LISTEN, $context);
        
        if (!$server) {
            $this->error("Failed to create server: $errstr ($errno)");
            return;
        }

        // Set server socket to non-blocking mode
        stream_set_blocking($server, 0);
        
        $this->info('WebSocket server is running on ws://127.0.0.1:6001');
        
        while (true) {
            // Reset arrays for stream_select
            $this->read = array_merge([$server], $this->clients);
            $this->write = $this->except = [];
            
            // Wait for activity on any socket
            if (stream_select($this->read, $this->write, $this->except, null) > 0) {
                // Check for new connections
                if (in_array($server, $this->read)) {
                    $client = stream_socket_accept($server);
                    
                    if ($client) {
                        if (count($this->clients) >= $this->maxConnections) {
                            $this->warn('Maximum connections reached. Rejecting new connection.');
                            fwrite($client, "HTTP/1.1 503 Service Unavailable\r\n\r\n");
                            fclose($client);
                            continue;
                        }

                        // Set client socket to non-blocking mode
                        stream_set_blocking($client, 0);
                        
                        $this->clients[] = $client;
                        $this->info('New client connected. Total connections: ' . count($this->clients));
                        
                        // Handle WebSocket handshake
                        if (!$this->handleHandshake($client)) {
                            $this->removeClient($client);
                            continue;
                        }
                    }
                }

                // Handle client messages
                foreach ($this->clients as $client) {
                    if (in_array($client, $this->read)) {
                        $data = fread($client, 8192);
                        
                        if ($data === false || $data === '') {
                            $this->removeClient($client);
                            continue;
                        }

                        // Parse WebSocket frame
                        $frame = $this->parseFrame($data);
                        if ($frame) {
                            $this->info('Received message: ' . $frame);
                            // Broadcast to all clients
                            $this->broadcast($frame);
                        }
                    }
                }
            }
        }
    }

    protected function handleHandshake($client)
    {
        $headers = '';
        while (($line = fgets($client)) !== false) {
            $headers .= $line;
            if ($line === "\r\n") break;
        }

        $this->info('Received headers: ' . $headers);

        // Parse headers and generate response
        $key = '';
        if (preg_match('/Sec-WebSocket-Key: (.*)\r\n/', $headers, $matches)) {
            $key = $matches[1];
        }

        if (empty($key)) {
            $this->error('No WebSocket key found in headers');
            return false;
        }

        $accept = base64_encode(sha1($key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11', true));

        $response = "HTTP/1.1 101 Switching Protocols\r\n";
        $response .= "Upgrade: websocket\r\n";
        $response .= "Connection: Upgrade\r\n";
        $response .= "Sec-WebSocket-Accept: $accept\r\n";
        $response .= "Sec-WebSocket-Version: 13\r\n\r\n";

        if (fwrite($client, $response) === false) {
            $this->error('Failed to send handshake response');
            return false;
        }

        $this->info('Handshake completed successfully');
        return true;
    }

    protected function handleClient($client)
    {
        while (true) {
            $data = fread($client, 8192);
            
            if ($data === false || $data === '') {
                $this->removeClient($client);
                break;
            }

            // Parse WebSocket frame
            $frame = $this->parseFrame($data);
            if ($frame) {
                $this->info('Received message: ' . $frame);
                // Broadcast to all clients
                $this->broadcast($frame);
            }
        }
    }

    protected function parseFrame($data)
    {
        if (strlen($data) < 2) return null;

        $opcode = ord($data[0]) & 0x0F;
        $length = ord($data[1]) & 0x7F;
        $offset = 2;

        if ($length === 126) {
            $length = unpack('n', substr($data, 2, 2))[1];
            $offset += 2;
        } elseif ($length === 127) {
            $length = unpack('J', substr($data, 2, 8))[1];
            $offset += 8;
        }

        $mask = (ord($data[1]) & 0x80) !== 0;
        if ($mask) {
            $maskingKey = substr($data, $offset, 4);
            $offset += 4;
        }

        $payload = substr($data, $offset);
        if ($mask) {
            $payload = $this->unmask($payload, $maskingKey);
        }

        return $payload;
    }

    protected function unmask($payload, $maskingKey)
    {
        $result = '';
        for ($i = 0; $i < strlen($payload); $i++) {
            $result .= $payload[$i] ^ $maskingKey[$i % 4];
        }
        return $result;
    }

    protected function broadcast($message)
    {
        $disconnectedClients = [];
        foreach ($this->clients as $client) {
            $frame = $this->createFrame($message);
            if (fwrite($client, $frame) === false) {
                $disconnectedClients[] = $client;
            }
        }

        // Remove disconnected clients
        foreach ($disconnectedClients as $client) {
            $this->removeClient($client);
        }
    }

    protected function createFrame($message)
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

    protected function removeClient($client)
    {
        $key = array_search($client, $this->clients);
        if ($key !== false) {
            unset($this->clients[$key]);
            fclose($client);
            $this->info('Client disconnected. Total connections: ' . count($this->clients));
        }
    }
}
