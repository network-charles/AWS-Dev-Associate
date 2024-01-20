# Build Momentum With a Simple Docker Lab Hosted Locally
![unu933ml2k86emcydhj7](https://github.com/network-charles/AWS-Dev-Associate/assets/30233365/84dc578f-bf7e-4d88-ad6c-9a70211a41b4)

[Read the documentaion](https://dev.to/charlesuneze/docker-arp-analysis-guide-2fe5)

Now try this ECS Lab.

# Null Resource Code Explaination

### Grab ECS Task ID for the Container
`"echo 'Executing command...'; task_id=($(aws ecs list-tasks --cluster ecs | grep -o 'ecs/[^\"]*' | cut -d'/' -f2)); echo $task_id > task_id.txt"`


- grep -o 'ecs/[^"]*' extracts substrings starting with "ecs/" and ending before the next double-quote.
- cut -d'/' -f2 splits the string based on "/" and selects the second field.
- echo $task_id > task_id.txt" writes each value to a new file with the filename as task_id.

# Apply Your Terraform Configuration
terraform apply -auto-approve && task_id=$(cat task_id.txt)

### Code Explaination
-  Apply the defined infrastructure.
- Output the task_id from the file and save it as a variable named 'task_id'.

# Access the Shell of the Container
Copy and paste the aws cli output

# Clean Up
terraform destroy -auto-approve

Then delete the task_id.txt file.
