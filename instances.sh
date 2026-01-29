#!/bin/bash
ami="ami-0220d79f3f480ecf5"
sg="sg-03b441e0ba008f925"
zone="Z0711084A6IKM873A3LI"
record="rscloudservices.icu"

echo "Please enter the instances to be created followed by a space"
read instances



for instance in $instances
do
 start_time=$(date +%s)
 echo "Creating AWS instance $instance as requested"
 instance_id=$(aws ec2 run-instances --image-id $ami --instance-type t3.micro  --security-group-ids $sg  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
 end_time=$(date +%s)
 echo "$instance instance is created successfully"
 echo "Time taken to create instance is $(($end_time - $start_time))Seconds"
 sleep 10
 if [ $instance = frontend ]; then
  ip=$(aws ec2 describe-instances --region us-east-1 --filters "Name=instance-id,Values=$instance_id" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
else
  ip=$(aws ec2 describe-instances --region us-east-1 --filters "Name=instance-id,Values=$instance_id" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
fi
echo "ip for $instance is $ip"
rec=$(aws route53 change-resource-record-sets --hosted-zone-id "$zone" --change-batch '{
    "Comment": "Create or Update A record via script",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": ""$instance.$record"",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                    {
                        "Value": "192.0.2.50"
                    }
                ]
            }
        }
    ]
}'
)
echo "The r53 record for $instance is $rec"
done

