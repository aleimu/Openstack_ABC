#!/bin/sh

ip=172.28.0.2
user_name=root
user_pass=$1

copygaussdbalib()
{
    expect -c "
        spawn scp -r $user_name@$ip:$1 $1
        expect {
                \"*assword\" {set timeout 500; send \"${user_pass}\r\";}
                \"yes/no\" {send \"yes\r\"; exp_continue;}
                \"*No route to host\" { break }
                \"*o such file or director*\" { break }
               }
        expect eof"
}


libpath=(/usr/lib64/python2.7/site-packages/sqlalchemy  /usr/lib64/python2.7/site-packages/psycopg2  /usr/lib64/libpq.so.5.5  /usr/lib64/libpq.so.5  /usr/lib64/libpq.so)
echo $libpath
echo ${#libpath[@]}

for p in ${libpath[@]}; do
    echo $p
    copygaussdbalib $p
done
