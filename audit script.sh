#!/bin/bash

echo -e "NodeName | Status | AMI Age (Days)"

# Get list of nodes (no headers)
nodes=$(kubectl get nodes --no-headers | awk '{print $1, $2}')

for node_info in $nodes; do
  # Extract node name and status (careful with space splitting)
  node_name=$(echo $node_info | awk '{print $1}')
  node_status=$(echo $node_info | awk '{print $2}')
  
  # Get instance ID from providerID
  provider_id=$(kubectl get node $node_name -o jsonpath='{.spec.providerID}')
  # Extract instance ID from providerID
  # Format is like: aws:///region/instance-id
  instance_id=$(echo $provider_id | awk -F/ '{print $NF}')
  
  # Get AMI ID of instance
  ami_id=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].ImageId' --output text)

  # Get AMI creation date
  ami_creation_date=$(aws ec2 describe-images --image-ids $ami_id --query 'Images[0].CreationDate' --output text)
  
  # Convert AMI creation date to timestamp
  ami_timestamp=$(date -d "$ami_creation_date" +%s)
  current_timestamp=$(date +%s)

  # Calculate age in days
  ami_age=$(( (current_timestamp - ami_timestamp) / 86400 ))

  # Check if node is NotReady
  if [[ "$node_status" == "NotReady" ]]; then
    status="NotReady"
  else
    status="Ready"
  fi

  echo -e "$node_name | $status | $ami_age"
done
