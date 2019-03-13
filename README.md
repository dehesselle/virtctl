# virtctl - systemd service

## About

[virtctl](https://github.com/dehesselle/virtctl) is an instantiable systemd [service](https://www.freedesktop.org/software/systemd/man/systemd.service.html) for starting/stopping [libvirt](https://www.libvirt.org)-based virtual machines (it interacts with `virsh`). It works out of the box with libvirt's default directory layout, i.e. `systemctl start virtctl@DomainName` starts `/etc/libvirt/qemu/DomainName.xml`, but can also be easily configured if you keep your files somewhere else.

If you're looking for an easy and customizable way to start and stop your VMs with systemd, you might want to take a look!

## Setup

### Basics

Copy the files from this repository to the following directories (alternative: [AUR](https://aur.archlinux.org/packages/virtctl-git/)) and issue a `systemctl daemon-reload` afterwards:

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

In its default configuration, [virtctl](https://github.com/dehesselle/virtctl) can already start and stop your VMs if

1. you adopted libvirt's directory layout and keep your domain XML in `/etc/libvirt/qemu`
2. you kept your naming consistent, i.e. for every domain the filename `DomainName.xml` matches exactly with the real name inside the XML, `<name>DomainName</name>`.

If your domain XML is somewhere else, take a look at `file_layout.conf.example` on how to override that setting with a drop-in file. The second requirement however must always be followed. 

### Advanced

[virtctl](https://github.com/dehesselle/virtctl) provides its own mechanism to run "post start" and "post stop" actions for your VMs, similar to libvirt's own [hooks](https://www.libvirt.org/hooks.html). Just create a file `DomainName_startpost` and/or `DomainName_stoppost`, put your commands in there (these files get sourced by a bash shell, so no shebang!) and place it in `/etc/virtctl.d` _or_ in the directory your domain XML is in.  
If you have "post start" or "post stop" files in both locations, the one besides your domain XML takes precedence and the other one in `/etc/virtctl.d` will be ignored (they do not stack up / no include hierarchy).

#### port forwarding for NAT network

If you want to forward ports from your host to your guest, you can use the function `forward_port` in your "post start" action. Check the example in `instance_startpost.example`.  
Port forwardings are automatically cleared when the VM shuts down.

#### start/stop on host boot/shutdown

[virtctl](https://github.com/dehesselle/virtctl) provides a target named `hypervisor.target`. It depends on and is reached after `multi-user.target`. If you choose to `systemctl enable virtctl@DomainName`, it gets linked into `hypervisor.target.wants`.  
The intention is to stay clear of `multi-user.target` so that you have a way to easily enable (or disable) all VMs at once, be it temporarily with `systemctl isolate hypervisor` or permanent/on boot with `systemctl set-default hypervisor`.

### Limitations

- Multiple physical and/or virtual network adapters aren't supported.

## start and stop VM

```bash
systemctl start  virtctl@DomainName
systemctl status virtctl@DomainName
systemctl stop   virtctl@DomainName
```

If you want systemd to automatically start/stop your VMs on boot/shutdown, enable them and set your default target.

```bash
systemctl enable virtctl@DomainName
systemctl set-default hypervisor
```

 
## Famous last words

_"It should work!"_ - I'm using this myself on a daily basis on multiple Arch Linux boxes.

### Contributions

[virtctl](https://github.com/dehesselle/virtctl) is available in [AUR](https://aur.archlinux.org/packages/virtctl-git/), provided by [NihlisticPandemonium](https://github.com/nihilisticpandemonium). Thank you very much 🙂!

## License

[MIT](LICENSE)
