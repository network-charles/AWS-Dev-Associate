Requirements
=============

I recently made the switch to a Mac and found using `Multipass <https://multipass.run/>`_ from Canonical simpler than spinning up a VM with tools like Virtualbox. However, when it comes to container networking labs, non-Linux systems are not recommended. While I downloaded Docker Desktop for Mac, I had trouble seeing all the Docker network interfaces.
For Windows users, I will advise you to use WSL2 instead, it’s easier to deploy and manage compared to having to use a virtual machine like Virtualbox.
Keep in mind that the Ubuntu installation requirement is only for Mac and Linux users. This guide will use two terminal tabs throughout.

Install Homebrew and Multipass
-------------------------------

Download `Homebrew <https://brew.sh/>`_

.. code-block:: bash

   # Terminal-1 Mac/Linux
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Download Multipass
------------------

.. code-block:: bash

   # Terminal-1 Mac/Linux
   brew install multipass

Download an Ubuntu Server from Multipass
----------------------------------------

This Ubuntu server will be customized to run the same specifications as an AWS EC2-T2 Micro instance type.

- 1 CPU
- 1 GB of RAM
- 8 GB of disk
- version 22.04

Simple and fast, right?

.. code-block:: bash

   # Terminal-1 Mac/Linux
   multipass launch jammy --name=ubuntu --cpus=4 --disk=20G --memory=8G

jammy is the image `name <https://multipass.run/docs/create-an-instance#heading--create-an-instance-with-a-specific-image>`_ for Ubuntu server version 22.04.

Go to the Shell of the Ubuntu Server
------------------------------------

.. code-block:: bash

   # Terminal-1 Mac/Linux
   multipass shell ubuntu

Install Docker
--------------

Download `docker <https://docs.docker.com/engine/install/ubuntu/>`_ on the Ubuntu server.

.. code-block:: bash

   # Terminal-1 Ubuntu
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

   # Close this Ubuntu shell.
   # Sometimes you might need to use the exit command severally
   # to successfully exit the shell.
   exit

Mount a Local Folder to an Ubuntu Directory
-------------------------------------------

Mount the `Documents/` folder in your Mac, or other machine to the `mnt/` directory in the Ubuntu server running inside Multipass.

.. code-block:: bash

   # Terminal-1 Mac/Linux
   multipass mount /Users/apple/Documents /mnt/
   Verify Ubuntu Server Installation

.. code-block:: bash
   
   apple@Charles-MBP ~ % multipass info ubuntu
   Name:           ubuntu
   State:          Running
   Snapshots:      0
   IPv4:           192.168.64.4
                  172.17.0.1
   Release:        Ubuntu 22.04.3 LTS
   Image hash:     9dxa2awl28c8 (Ubuntu 22.04 LTS)
   CPU(s):         1
   Load:           0.00 0.00 0.00
   Disk usage:     2.3GiB out of 7.7GiB
   Memory usage:   201.4MiB out of 951.6MiB
   Mounts:         /Users/apple/Documents => /mnt
                     UID map: 501:default
                     GID map: 20:default

Install Wireshark
-----------------
Choose your preferred machine and `download <https://www.wireshark.org/download.html>`_.
