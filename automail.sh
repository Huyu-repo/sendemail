#!/bin/bash
HOSTNAME="127.0.0.1"                                           
PORT="3306"
USERNAME="root"
PASSWORD="123"
DBNAME="abm"
TABLENAME="abm_audience"
DATE=`date  "+%Y-%m-%d"`

select_sql="SELECT 
abm_au.tenant_id,
SUM(CASE 
	WHEN abm_au.status = 'DISTRIBUTED' 
	AND  DATE_FORMAT(abm_au.update_time,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(NOW(),INTERVAL 15 DAY),'%Y-%m-%d') 
	AND DATE_FORMAT(abm_au.update_time, '%Y-%m-%d') < DATE_FORMAT(NOW(),'%Y-%m-%d')
	THEN 1 	
	ELSE 0
END) AS distributedCount,
SUM(CASE 
	WHEN abm_au.status = 'READY' 
	AND DATE_FORMAT(abm_au.created_time,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(NOW(),INTERVAL 15 DAY),'%Y-%m-%d')
	AND DATE_FORMAT(abm_au.created_time,'%Y-%m-%d') < DATE_FORMAT(NOW(),'%Y-%m-%d')
	THEN 1 	
	ELSE 0	
END) AS builtCount
FROM abm_audience abm_au LEFT JOIN sso.tenant te ON te.tenant_id = abm_au.tenant_id
WHERE te.tenant_sysname IS NOT NULL AND te.platform_type='MVPD'
GROUP BY abm_au.tenant_id"





/usr/local/mysql/bin/mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} abm -e "${select_sql}" > $DATE.txt



email_receiver=13040291896@163.com
email_sender=dana.zhou@liveramp.com
email_username=dana.zhou@liveramp.com
email_password=Qaz430128+
email_smtphost=smtp.gmail.com
email_title="Distributed and created audience statistics fortnightly"
email_content="sent by danazhou"



/usr/local/bin/sendEmail -f ${email_sender} -t ${email_receiver} -s ${email_smtphost}:8086 -u ${email_title} -xu ${email_username} -o tls=yes -a $DATE.txt -xp ${email_password} -m ${email_content} -o message-charset=utf-8
