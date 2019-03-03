# virtctl - systemd service
## About
[virtctl](https://github.com/dehesselle/virtctl) is an instantiable systemd service for starting/stopping libvirt-based virtual machines (it interacts with `virsh`). It works out of the box with libvirt's default file/directory layout, i.e. `systemctl start virtctl@DomainName` starts `/etc/libvirt/qemu/DomainName.xml`, but can also be easily configured if you keep your files somewhere else. 

If you're looking for an easy and customizable way to start and stop your VMs with systemd, you might want to take a look!

## Getting started
### Basics
Copy the files to the following directories and issue a `systemctl daemon-reload` afterwards:
```
root
┣━━━etc
┃   ┣━━━systemd
┃   ┃   ┗━━━system 
┃   ┃       ┣━━━hypervisor.target
┃   ┃       ┣━━━virtctl@.service
┃   ┃       ┗━━━virtctl@.service.d
┃   ┃           ┗━━━file_layout.conf.example
┃   ┗━━━virtctl.d
┃       ┣━━━functions.sh
┃       ┣━━━instance_startpost.example
┃       ┗━━━instance_stoppost.example
┃
...
```
This is the full installation. For a minimal installation, only `virtctl@.service` is required (at the expense of some functionalities, of course).

In its default configuration, virtctl can already start and stop your VMs if
1. you stuck with the file/folder structure as proposed by libvirt, i.e. your domain XML is in `/etc/libvirt/qemu`
2. you kept your naming consistent, i.e. for every domain the filename `DomainName.xml` matches exactly with the real name inside the XML, `<name>DomainName</name>`.

If your domain XML is somewhere else, take a look at `file_layout.conf.example` on how to override that setting with a drop-in file. The second requirement however must always be followed. 

### Advanced
virtctl provides a mechanism to run "post start" and "post stop" actions for your VMs. Just create a file `DomainName_startpost` and/or `DomainName_stoppost` and place it in `/etc/virtctl.d` or in the directory your domain XML is in. If the same file is found in both locations, the file besides your domain XML takes precedence and the other one is ignored. 

#### port forwarding for NAT network
For the special case of requiring a "post start" action to forward ports from your host to your guest, virtctl provides a function `forward_port` that you can use. You can find examples on how to use it in `instance_startpost.example`.  
Port forwardings are automatically cleared when the VM shuts down.

The most relevant use case is probably to automatically have some ports forwarded to your (NATed) VMs.

#### start/stop on host boot/shutdown
virtctl provides a target named `hypervisor.target`. If you choose to `systemctl enable virtctl@DomainName`, it gets linked into `hypervisor.target.wants` in order to not pollute your `multi-user.target`. You can then `systemctl set-default hypervisor.target` to have your VMs started by virtctl on next boot.

### Limitations
- Multiple physical and/or virtual network adapters aren't supported. TODO whats the status

### 3...2...1... go!
If you haven't done already, issue a `systemctl start virtctl@DomainName` and check the status with `systemctl status virtctl@DomainName`.

If you want systemd to automatically start and stop it on boot/shutdown, enable it with `systemctl enable vm@debian` and change your default target with `systemctl set-default hypervisor`.

## Famous last words
_"It should work!"_ - I'm using this myself on a daily basis on multiple Arch Linux boxes.

TODO something else?

### Contributions
There is a PKGBUILD created by [NihlisticPandemonium](https://github.com/nihilisticpandemonium), so virtctl is available in [AUR](https://aur.archlinux.org/packages/virtctl-git/) - thank you very much 🙂!

## License
[MIT](LICENSE)
