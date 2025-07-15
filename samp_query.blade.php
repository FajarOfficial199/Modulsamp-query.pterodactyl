@if($data['success'])
    <div class="row">
        <div class="col-xs-12">
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title">SA-MP Server Info</h3>
                </div>
                <div class="box-body">
                    <div class="row">
                        <div class="col-md-6">
                            <dl class="dl-horizontal">
                                <dt>Hostname</dt>
                                <dd>{{ $data['data']['hostname'] }}</dd>
                                
                                <dt>Address</dt>
                                <dd>{{ $data['data']['address'] }}:{{ $data['data']['port'] }}</dd>
                                
                                <dt>Gamemode</dt>
                                <dd>{{ $data['data']['gamemode'] }}</dd>
                                
                                <dt>Map</dt>
                                <dd>{{ $data['data']['mapname'] }}</dd>
                            </dl>
                        </div>
                        <div class="col-md-6">
                            <dl class="dl-horizontal">
                                <dt>Players</dt>
                                <dd>{{ $data['data']['online'] }} / {{ $data['data']['maxplayers'] }}</dd>
                                
                                <dt>Password</dt>
                                <dd>{{ $data['data']['passworded'] ? 'Yes' : 'No' }}</dd>
                                
                                <dt>Version</dt>
                                <dd>{{ $data['data']['rules']['version'] ?? 'Unknown' }}</dd>
                                
                                <dt>Website</dt>
                                <dd>{{ $data['data']['rules']['weburl'] ?? 'None' }}</dd>
                            </dl>
                        </div>
                    </div>
                    
                    @if(!empty($data['data']['players']))
                        <div class="row">
                            <div class="col-xs-12">
                                <h4>Online Players ({{ count($data['data']['players']) }})</h4>
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Name</th>
                                                <th>Score</th>
                                                <th>Ping</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach($data['data']['players'] as $player)
                                                <tr>
                                                    <td>{{ $player['id'] }}</td>
                                                    <td>{{ $player['name'] }}</td>
                                                    <td>{{ $player['score'] }}</td>
                                                    <td>{{ $player['ping'] }}</td>
                                                </tr>
                                            @endforeach
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    @else
                        <p class="text-muted">No players online</p>
                    @endif
                </div>
            </div>
        </div>
    </div>
@else
    <div class="alert alert-warning">
        <i class="fa fa-warning"></i> Unable to query SA-MP server: {{ $data['error'] }}
    </div>
@endif
