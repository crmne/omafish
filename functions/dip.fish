function dip --description 'stop SSH port forwarding for given ports'
    if test (count $argv) -eq 0
        echo "Usage: dip <port1> [port2] ..."
        return 1
    end

    for port in $argv
        pkill -f "ssh.*-L $port:localhost:$port"
        and echo "Stopped forwarding port $port"
        or echo "No forwarding on port $port"
    end
end
