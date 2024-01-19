#!/bin/bash

######################################################################################
#
# Description:
# ------------
#	Initialize Wireguard setup, start wireguard tunnel and setup firewall rules
#   for VPN tunnels. As firewall rules may be reseted whenever ruleset is changed
#   in GUI, this script should be executed regularly to ensure that VPN firewall 
#   is permanently activated.
#
######################################################################################

##############################################################################################
#
# Configuration
#

# directory with wireguard config files. All *.conf files in
# the directory will be considered as valid wireguard configs
conf_dir="/data/custom/wireguard/"

#
# No further changes should be necessary beyond this line.
#
######################################################################################


# set scriptname
me=$(basename $0)

# include local configuration if available
[ -e "$(dirname $0)/${me%.*}.conf" ] && source "$(dirname $0)/${me%.*}.conf"

for conf_file in ${conf_dir}/*.conf; do
    if [ $conf_file != "${me%.*}.conf" ]; then

        wg_if=$(basename $conf_file .conf)
        wg show $wg_if || wg-quick up $conf_file

        # As ruleset is reset, when changes are made via GUI it can be assumed that script
        # can be stopped when wireguard interfaces are not considered in fw rule set.
        if ( iptables --list-rules | grep -e "-i $wg_if " &> /dev/null &&  ip6tables --list-rules | grep -e "-i $wg_if "  &> /dev/null ); then 
            logger "$me: Found wireguard rules for $wg_if. Nothing to do."
        else

            #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # add rule for VPN interface to UBIOS_INPUT_USER_HOOK  
            #
            rule="-A UBIOS_INPUT_USER_HOOK -i _IF_ -j UBIOS_LAN_LOCAL_USER"
            iptables ${rule/_IF_/$wg_if} &&
                logger "$me: added IPv4 rule: ${rule/_IF/$wg_if}" ||
                logger "$me: failed to add IPv4  ${rule/_IF/$wg_if}"
            ip6tables ${rule/_IF_/$wg_if} &&
                logger "$me: added IPv6 rule: ${rule/_IF/$wg_if}" ||
                logger "$me: failed to add IPv6 ${rule/_IF/$wg_if}"

            #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # add rule for VPN interface to UBIOS_FORWARD_IN_USER
            #
            rule="-A UBIOS_FORWARD_IN_USER -i _IF_ -j UBIOS_LAN_IN_USER"
            iptables ${rule/_IF_/$wg_if} &&
                logger "$me: added IPv4 rule: ${rule/_IF/$wg_if}" ||
                logger "$me: failed to add IPv4  ${rule/_IF/$wg_if}"
            ip6tables ${rule/_IF_/$wg_if} &&
                logger "$me: added IPv6 rule: ${rule/_IF/$wg_if}" ||
                logger "$me: failed to add IPv6 ${rule/_IF/$wg_if}"

            #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # add rule for VPN interface to UBIOS_FORWARD_OUT_USER 
            #
            rule="-A UBIOS_FORWARD_OUT_USER -o _IF_ -j UBIOS_LAN_OUT_USER"
            iptables ${rule/_IF_/$wg_if} &&
                logger "$me: added IPv4 rule: ${rule/_IF/$wg_if}" ||
                logger "$me: failed to add IPv4  ${rule/_IF/$wg_if}"
            ip6tables ${rule/_IF_/$wg_if} &&
                logger "$me: added IPv6 rule: ${rule/_IF/$wg_if}" ||
                logger "$me: failed to add IPv6 ${rule/_IF/$wg_if}"

            #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # add allow related/established to UBIOS_LAN_IN_USER if necessary
            #
            rule="-A UBIOS_LAN_IN_USER -m conntrack --ctstate RELATED,ESTABLISHED.*-j RETURN"
            iptables --list-rules | grep -e "$rule" &> /dev/null || 
                iptables -I UBIOS_LAN_IN_USER 1 -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
            ip6tables --list-rules | grep -e "$rule" &> /dev/null || 
                ip6tables -I UBIOS_LAN_IN_USER 1 -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN

        fi
    fi
done
