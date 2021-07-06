sudo podman run --rm \
           --interactive \
           --tty \
           --privileged \
           --net host \
           --volume "$(pwd)/haproxy.cfg:/etc/haproxy/haproxy.cfg" \
           --security-opt label=disable \
           --name haproxy localhost/kevydotvinu/haproxy
