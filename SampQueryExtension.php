<?php

namespace App\Extensions\ServerInfo;

use Exception;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\View;
use Pterodactyl\Extensions\ServerInfo\ServerInfoInterface;

class SampQueryExtension implements ServerInfoInterface
{
    public $cachePrefix = 'samp_query_data.';
    public $cacheTime = 30; // seconds

    public function name()
    {
        return 'SA-MP Server Query';
    }

    public function route()
    {
        return 'extensions.samp-query';
    }

    public function view()
    {
        return 'extensions.samp_query';
    }

    public function getData(array $server)
    {
        $key = $this->cachePrefix . $server['uuid'];
        
        return Cache::remember($key, $this->cacheTime, function () use ($server) {
            try {
                $node = $server['node'];
                $port = $server['allocation']['port'];
                
                $nodePath = '/usr/bin/node';
                $scriptPath = base_path('app/Extensions/ServerInfo/samp-query.js');
                
                $command = escapeshellcmd("{$nodePath} {$scriptPath} {$node} {$port}");
                $result = shell_exec($command);
                
                $data = json_decode($result, true);
                
                if (json_last_error() !== JSON_ERROR_NONE || !$data) {
                    throw new Exception('Invalid server response');
                }
                
                return [
                    'success' => true,
                    'data' => $data,
                ];
            } catch (Exception $e) {
                Log::error('SA-MP Query Error: ' . $e->getMessage());
                
                return [
                    'success' => false,
                    'error' => 'Failed to query server',
                ];
            }
        });
    }
}
