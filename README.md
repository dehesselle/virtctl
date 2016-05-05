# vmmctl
## About
[vmmctl](https://github.com/dehesselle/vmmctl) is a helper script for starting/stopping libvirt-based virtual machines and the infrastructure around it to integrate it with systemd. If you're looking for a small and simple framework to start and stop your VMs with systemd, you might want to take a look.

## Getting started
### Requirements
For all of this to work you need to
- have a common directory where all your VMs are stored (well at least the Domain XML)
- put each VM in a subdirectory below this common directory
- name those subdirectories like the Domain XML files they contain (without the `.xml` suffix)
- name your Domain XML files like the VMs

_(The sole purpose of these requirements is to keep the scripts simple.)_

#### Example
Let's say you have two VMs, `debian` and `ubuntu`. Both consist of a Domain XML and an (hdd-) image file. You choose `/srv/kvm` as a common directory.
```
/srv/kvm/ubuntu/ubuntu.xml
/srv/kvm/ubuntu/ubuntu.img
/srv/kvm/debian/debian.xml
/srv/kvm/debian/debian.img
```

### Basic layout
Copy the files from the git repository into the locations as shown below.
#### system files (mandatory)
```
/etc/systemd/system/vm@.service
/etc/systemd/system/hypervisor.target
/usr/local/etc/vmmctl.conf
/usr/local/sbin/vmmctl
```
#### vm specific files (optional)
According to the example above.
```
/srv/kvm/debian/post_start
/srv/kvm/debian/post_stop
/srv/kvm/ubuntu/post_start
/srv/kvm/ubuntu/post_stop
```
__Hint:__ These two scripts are optional - `vmmctl` checks for their presence and will do just fine without them.
### Configuration
- change the parameter `DOMAIN_ROOT_DIR` in `vmmctl.conf` according to the name of your common directory
- change the parameter `VIRTUAL_NETWORK` to the name of your virtual network
- The `post_start` and `post_stop` scripts won't do anything in their default state, everything has been commented out. They are already prepared to handle port forwarding but you're encouraged to put any start/stop task in there that you require.
- reload systemd with `systemctl daemon-reload`

### 3...2...1...Go!
Start your VM with `systemctl start vm@debian`. Check if it came up with `systemctl status vm@debian` and take a look at the logfile (`LOGFILE` in `vmmctl.conf`).

If you want systemd to automatically start and stop it on boot/shutdown, enable it with `systemctl enable vm@debian` and change your default target with `systemctl set-default hypervisor`.

## Famous last words
_It should work!_ - I'm using this myself on a daily basis. Granted, my setup is rather simple because I don't have to deal with multiple physical or virtual networks and I can live with the (mostly naming related) requirements above. That's where this solution falls short.
