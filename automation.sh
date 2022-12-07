#sudo apt update -y

pkg=apache2
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  sudo apt install $pkg
fi

status=$(service apache2 status)

if [[ $status == *"active (running)"* ]]; then
  echo "Process is running"
else 
	echo "Process is not running : Starting process"
	sudo systemctl start $pkg
fi

enableStatus=$(systemctl is-enabled $pkg)
echo $enableStatus
if [[ $enableStatus != "enabled" ]]
then
	sudo systemctl enable $pkg
fi


timestamp=$(date '+%d%m%Y-%H%M%S')
myname='Priyanka'

tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
s3_bucket='upgrad-priyanka'

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar


if [ -e /var/www/html/inventory.html ]
then
    echo "File exists"
else
    echo "Creating html file"
    touch /var/www/html/inventory.html
    echo "Log Type         Time Created         Type        Size ">> /var/www/html/inventory.html 
fi

echo "" >>/var/www/html/inventory.html
echo "httpd-logs	$timestamp		tar	$(stat -c%s /tmp/${myname}-httpd-logs-${timestamp}.tar)" >>/var/www/html/inventory.html	

if [ -e /etc/cron.d/automation ]
then
	echo "Automation File Exists"
else
	touch /etc/cron.d/automation
	echo "* * * * * root /home/ubuntu/GIT/Automation_Project/automation.sh">> /etc/cron.d/automation
	
fi


