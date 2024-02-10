# Create a null resource to execute a local command after the ECS service is created.
resource "null_resource" "grab_task_id" {
  provisioner "local-exec" {
    command = <<-EOT
      echo 'Executing command...'
      # Retrieve the task ID from ECS and store it in a file.
      task_id=($(aws ecs list-tasks --cluster ecs | grep -o 'ecs/[^\"]*' | cut -d'/' -f2))
      echo $task_id > task_id.txt
    EOT
  }

  depends_on = [aws_ecs_service.service]
}

# SSH into the instance and mount the EFS file system.
resource "null_resource" "mount_efs" {
  count = 2

  triggers = {
    efs = data.aws_efs_mount_target.efs.ip_address
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        # Change the current directory to the root directory ('/')
        cd /

        # Use 'sudo su -c' to execute the following command as the superuser
        sudo su -c "echo '${self.triggers.efs}:/ mnt/efs/fs1/ nfs defaults,_netdev 0 0' >> /etc/fstab" 

        # Mount the EFS file system immediately without requiring a system reboot
        sudo mount -a

        # Navigate to the efs mount
        cd mnt/efs/fs1/

        # Delete all existing files
        sudo rm -rf *

        # Create the index.html file with specified content
        sudo sh -c 'cat <<EOF > index.html
        <html>
            <body>
                <h1>It Works!</h1>
                <p>You are using an Amazon EFS file system for persistent container storage.</p>
            </body>
        </html>
        EOF'
      EOT
    ]

    connection {
      type        = "ssh"
      host        = count.index % 2 == 0 ? data.aws_instance.eu_west_2a.public_ip : data.aws_instance.eu_west_2b.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.key.private_key_pem
    }
    
  }

  depends_on = [aws_efs_mount_target.mount[0], aws_ecs_task_definition.nginx]
}
