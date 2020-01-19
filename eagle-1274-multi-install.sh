#!/bin/bash
OE_USER="eagle1274"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
OE_PORT="8074"
OE_SUPERADMIN="admin"
OE_CONFIG="${OE_USER}-server"
OE_DBHOST='localhost'
OE_DBPORT='5432'


#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
# universe package is for Ubuntu 18.x
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y

#echo -e "\n---- Creating the Eagle12 PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true
echo -e "* Create server config file"

echo -e "\n---- Create Eagle system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'EAGLE1274' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER


sudo touch /etc/${OE_CONFIG}.conf
echo -e "* Creating server config file"
sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'db_host = ${OE_DBHOST}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'db_port = ${OE_DBPORT}\n' >> /etc/${OE_CONFIG}.conf"

sudo su root -c "printf 'addons_path=/eagle1266/eagle1266-server/addons,/eagle1266/custom/addons\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'db_user = ${OE_USER}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'db_passwrord = ${OE_SUPERADMIN}\n' >> /etc/${OE_CONFIG}.conf"

sudo su root -c "printf 'admin_passwd = ${OE_SUPERADMIN}\n' >> /etc/${OE_CONFIG}.conf"

sudo su root -c "printf 'xmlrpc_port = ${OE_PORT}\n' >> /etc/${OE_CONFIG}.conf"

sudo su root -c "printf 'logfile = /var/log/${OE_USER}/${OE_CONFIG}.log\n' >> /etc/${OE_CONFIG}.conf"


sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u eagle1266 eagle1266-server/openerp-server --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
cat <<EOF > ~/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Enterprise Business Applications
# Description: ODOO Business Applications
### END INIT INFO

[Unit]
Description=Eagle
Documentation=http://www.eagle-erp.com
[Service]
#Ubuntu/Debian Convention:
Type:simple
User=shaheen
ExecStart=/eagle1266/eagle1266-server/eagle-bin -c /etc/${OE_CONFIG}.conf
[Install]
WantedBy=default.target

