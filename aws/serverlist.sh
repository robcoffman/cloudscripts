#!/bin/bash

regions=( us-east-1 )
data_string=''
for r in "${regions[@]}"
do
        instance_info=$(aws ec2 describe-instances --query 'Reservations[].Instances[].[Placement.AvailabilityZone,State.Name,InstanceId,Platform,InstanceType,PrivateIpAddress,PublicIpAddress,Tags[?Key==`Name`].Value,Tags[?Key==`Project`].Value,Tags[?Key==`Env`].Value,Tags[?Key==`EnvType`].Value]' --region $r)
#  instance_info=$(aws ec2 describe-instances --query 'Reservations[].Instances[].[Placement.AvailabilityZone,State.Name,InstanceId,Platform,InstanceType,PrivateIpAddress,PublicIpAddress,Tags[?Key==`Name`].Value],Tags[?Key==`Project`].Value],Tags[?Key==`Env`].Value]' --region $r)

        for i in $instance_info
        do
                data_string="$data_string $i"

        done
done
echo $data_string > output.txt
echo "Region,Status,Instance_ID,OS,Instance_Size,Private,Public,Name,Project,Env,EnvType" > Server_List.csv

cat output.txt | sed 's|] ],|] ],\n|g'  | sed 's|] ] ]|] ] ]\n|g' | sed 's|null ],|null ],\n|g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/\"//g' >> Server_List.csv

