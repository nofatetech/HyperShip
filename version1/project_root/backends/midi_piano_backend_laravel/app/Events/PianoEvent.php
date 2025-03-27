<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class PianoEvent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $note;
    public $velocity;
    public $timestamp;

    /**
     * Create a new event instance.
     */
    public function __construct($note, $velocity, $timestamp)
    {
        $this->note = $note;
        $this->velocity = $velocity;
        $this->timestamp = $timestamp;
        
        Log::info('Piano event created', [
            'note' => $note,
            'velocity' => $velocity,
            'timestamp' => $timestamp
        ]);
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        Log::info('Broadcasting piano event on channel: piano-channel');
        return [
            new Channel('piano-channel')
        ];
    }
}
