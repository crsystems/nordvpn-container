FROM library/debian:latest

COPY ./nordvpn-repo.deb /root/nordvpn-repo.deb
COPY ./nvpn-script.sh /root/nvpn-script.sh

RUN chmod +x /root/nvpn-script.sh

RUN ["apt-get", "update"] 
RUN ["apt-get", "-y", "upgrade"]
RUN ["apt-get", "-y", "dist-upgrade"]
RUN ["apt-get", "-y", "--fix-broken", "install", "gnupg"]
RUN ["apt-get", "-y", "install", "curl", "wget"]
RUN wget https://repo.nordvpn.com/gpg/nordvpn_public.asc -O - | apt-key add -
RUN ["dpkg", "--install", "/root/nordvpn-repo.deb"]
RUN ["apt-get", "update"]
RUN ["apt-get", "download", "nordvpn"]
RUN dpkg --unpack nordvpn*.deb
RUN ["rm", "/var/lib/dpkg/info/nordvpn.postinst", "-f"]
RUN ["apt-get", "-y", "--fix-broken", "install"]
RUN rm nordvpn*

#ENTRYPOINT mkdir /dev/net && mknod /dev/net/tun c 10 200 && iptables -t nat -A POSTROUTING -s 172.17.0.1 -d 0.0.0.0/0 -j MASQUERADE && iptables -t filter -I INPUT -s 172.17.0.1/16 -d 172.17.0.2/16 -j ACCEPT && /bin/bash -c "nordvpnd &" && nordvpn login -u $NORDVPN_USER -p $NORDVPN_PASS && nordvpn connect $NORDVPN_SERVER_DNS && /bin/bash -c 'watch -n60 "nordvpn status" > /var/log/nordvpn-status 2>&1'

ENTRYPOINT /root/nvpn-script.sh
