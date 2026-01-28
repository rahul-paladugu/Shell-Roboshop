#!/bin/bash
ami="ami-0220d79f3f480ecf5"
sg="sg-03b441e0ba008f925"
instances="mongodb, frontend, webserver"



for instance in $instances
do
echo "Creating AWS INstances as requested"
instance_id=$(aws ec2 run-instances --image-id $ami --instance-type t3.micro  --security-group-ids $sg  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
done
echo $instance_id