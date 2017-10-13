# virtctl
## About
[virtctl](https://github.com/dehesselle/virtctl) is a helper script for starting/stopping libvirt-based virtual machines and the infrastructure around it to integrate it with systemd. If you're looking for a small and simple framework to start and stop your VMs with systemd, you might want to take a look.

## Getting started
### Requirements
The sole purpose of these requirements is to keep the scripts simple (i.e. they can easily guess path- and filenames).
#### folder structure and naming
- Make sure that your domain XML files are named exactly like the VMs themselves.
- Choose a common root directory. All domain XML files will be put in subdirectories below this root directory.
- Create subdirectories below the common root directory, one for each VM. Name them like you named your VMs.
- Place each VM's domain XML into one of those subdirectories.

Sounds confusing? Well, that's only me not being able to get it across. Take a look at the example below.

##### Example
Let's say you have two VMs, `debian` and `ubuntu`. Both consist of a Domain XML and an (hdd-) image file. You choose `/srv/kvm` as a common directory. According to the requirements above, you'll end up with the following file- and foldernames.
```
/srv/kvm/ubuntu/ubuntu.xml
/srv/kvm/ubuntu/ubuntu.img
/srv/kvm/debian/debian.xml
/srv/kvm/debian/debian.img
```
### Limitations
- Multiple physical and/or virtual network adapters aren't supported. This also implies that only one virtual network is supported.

### Basic layout
Copy the files from the git repository into the locations as shown below.
#### system files (mandatory)
```
/etc/systemd/system/vm@.service
/etc/systemd/system/hypervisor.target
/usr/local/etc/virtctl.conf
/usr/local/sbin/virtctl
```
#### vm specific files (optional)
According to the example above.
```
/srv/kvm/debian/post_start
/srv/kvm/debian/post_stop
/srv/kvm/ubuntu/post_start
/srv/kvm/ubuntu/post_stop
```
__Hint:__ These two scripts (per VM) are optional - [virtctl](https://github.com/dehesselle/virtctl) checks for their presence and will do just fine without them.
### Configuration
- Change the parameter `DOMAIN_ROOT_DIR` in `virtctl.conf` according to the name of your common root directory.
- Change the parameter `VIRTUAL_NETWORK` to the name of your virtual network.
- The `post_start` and `post_stop` scripts won't do anything in their default state, everything has been commented out. They are already prepared to handle port forwarding but you're encouraged to put any start/stop task in there that you require.
- Reload systemd's configuration with `systemctl daemon-reload`

### 3...2...1...Go!
Accoring to the example above: start your VM with `systemctl start vm@debian`. Check if it came up with `systemctl status vm@debian` and take a look at the logfile (`LOGFILE` in `virtctl.conf`, default is `/var/log/virtctl.log`).

If you want systemd to automatically start and stop it on boot/shutdown, enable it with `systemctl enable vm@debian` and change your default target with `systemctl set-default hypervisor`.

## Famous last words
_It should work!_ - I'm using this myself on a daily basis. Granted, my setup is rather simple because I don't have to deal with multiple physical or virtual networks and I can live with the naming-related requirements above. On the other hand, if you have a more complex setup, that is where this solution falls short.  

### Todos
- get virtual network name from XML
- provide a hook script (see [libvirt wiki]( http://wiki.libvirt.org/page/Networking/#Forwarding_Incoming_Connections))
