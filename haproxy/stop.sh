sudo podman kill $(sudo podman ps -a | grep haproxy | awk '{print $1}')
sudo podman rm -f $(sudo podman ps -a | grep haproxy | awk '{print $1}')
