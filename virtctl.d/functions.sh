#############################################
#                                           #
#   /etc/virtctl.d/global.bash              #
#                                           #
#   https://github.com/dehesselle/virtctl   #
#                                           #
#############################################

#
# - UPPERCASE variables are global variables set by the virtctl service
#   before sourcing this file.
#

# NAT only: get domain's internal IP address
function get_domain_ip
{
  local domain=$1
  local interface=$2   # argument is optional

  [ -z $interface ] && interface=vnet0   # set default value

  local seconds=0
  while [ $seconds -lt 60 ]; do
    if [ $((seconds%5)) -eq 0 ]; then   # every 5 seconds
      # get output form domifaddr command,
      # only keep the third line (lines 1-2: header),
      # only keep the fourth argument (ip/mask),
      # only keep the first argument (ip)      
      local domain_ip=$(virsh domifaddr $domain $interface |
        sed -n '3p' | 
        awk '{ print $4 }' |
        awk -F "/" ' { print $1 }')

      [ ! -z $domain_ip ] && break   # we got the IP address
    fi
      sleep 1
      ((seconds++))
   done

   echo $domain_ip
}

# NAT only: forward port from host to guest
function forward_port   # uses functions/variables from the environment
{
  local host_port=$1
  local guest_port=$2
  local guest_interface=$3   # argument is optional

  [ -z $guest_interface ] && guest_interface=vnet0   # set default value
  local guest_ip=$(get_domain_ip $DOMAIN $guest_interface)

  [ -z $host_port ] && (echo "$FUNCNAME: host_port missing" && return 1)
  [ -z $guest_port ] && (echo "$FUNCNAME: guest_port missing" && return 1)
  [ -z $guest_ip ] && (echo "$FUNCNAME: guest_ip missing" && return 1)

  iptables -t nat -A PREROUTING -p tcp --dport "$host_port" -j DNAT --to "$guest_ip:$guest_port"
  iptables -I FORWARD -d "$guest_ip/32" -p tcp -m state --state NEW -m tcp --dport "$guest_port" -j ACCEPT
}

# NAT only: remove all forwarded ports
function remove_all_forwardings
{
  local guest_interface=$1

  [ -z $guest_interface ] && guest_interface=vnet0   # set default value
  local guest_ip=$(get_domain_ip $DOMAIN $guest_interface)

  for rule in $(iptables -t nat -L PREROUTING --line-numbers | grep $guest_ip | awk '{ print $1 }'); do
    iptables -t nat -D PREROUTING $rule
  done

  for rule in $(iptables -L FORWARD --line-numbers | grep $guest_ip | awk '{ print $1 }'); do
    iptables -D FORWARD $rule
  done
}

function port_forwarding_del   # uses functions/variables from the environment
{
   local host_port=$1
   local guest_port=$2
#  '$domain': start_post > exec_post > port_forwarding_add
   local guest_ip=$(get_ip $domain)

   if [ -z "$host_port" ] || [ -z "$guest_ip" ] || [ -z "$guest_port" ]; then
      echo "error"
   else
      iptables -t nat -D PREROUTING -p tcp --dport "$host_port" -j DNAT --to "$guest_ip:$guest_port"
      iptables -D FORWARD -d "$guest_ip/32" -p tcp -m state --state NEW -m tcp --dport "$guest_port" -j ACCEPT
   fi
}

function virtctl_pre_stop
{
  remove_all_forwardings
}
