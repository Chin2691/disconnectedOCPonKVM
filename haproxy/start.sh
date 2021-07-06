podman run --detach \
      	--privileged \
      	--net host \
      	--volume "$(pwd)/haproxy.cfg:/etc/haproxy/haproxy.cfg" \
      	--security-opt label=disable \
      	--name haproxy localhost/kevydotvinu/haproxy
