#!/bin/bash
echo "AWS_Service,Region,Status,Instance_ID,OS,Instance_Size,Private,Public,Name,Project,Env,EnvType" > AWS_Services_List.csv

#Create Instance List
regions=( us-east-1 )
data_string=''
for r in "${regions[@]}"
do
        instance_info=$(aws ec2 describe-instances --query 'Reservations[].Instances[].[Placement.AvailabilityZone,State.Name,InstanceId,Platform,InstanceType,PrivateIpAddress,PublicIpAddress,Tags[?Key==`Name`].Value,Tags[?Key==`Project`].Value,Tags[?Key==`Env`].Value,Tags[?Key==`EnvType`].Value]' --region $r)

        for i in $instance_info
        do
                data_string="$data_string $i"

        done
done
echo $data_string > output.txt

cat output.txt | sed 's|] ],|] ],\n|g'  | sed 's|] ] ]|] ] ]\n|g' | sed 's|null ],|null ],\n|g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/\"//g' | sed '/^$/d' | sed 's/^/EC2\,/' >> AWS_Services_List.csv


#Create ELB List
list=$(aws elb describe-load-balancers --region us-east-1 --query 'LoadBalancerDescriptions[].[LoadBalancerName]' | sed 's|]||g' | sed 's|,||g' | sed 's|\[||g' | sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' | sed 's|\"||g')

for elb in $list
do
        elb_info=$(aws elb describe-tags --region us-east-1 --load-balancer-name $elb --query 'TagDescriptions[*].[Tags[?Key==`Project`].Value,Tags[?Key==`Env`].Value,Tags[?Key==`EnvType`].Value,LoadBalancerName]' | sed 's|] ],|] ],\n|g'  | sed 's|] ] ]|] ] ]\n|g' | sed 's|null ],|null ],\n|g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/\"//g' | sed ':a;N;$!ba;s/\n/ /g' |  sed 's/ //g' | awk -F, '{print "ELB,,,,,,,,"$4","$1","$2","$3","'})

echo $elb_info >> AWS_Services_List.csv

done
rm output.txt
