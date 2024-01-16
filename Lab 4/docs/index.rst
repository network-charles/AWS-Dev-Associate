.. Docker ARP Analysis Documentation master file, created by
   sphinx-quickstart on Tue Jan 16 08:15:13 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

=====================================================
Welcome to Docker ARP Analysis Documentation!
=====================================================

I've been immersing myself in CI/CD pipeline studies lately, and now that I've gotten a good grasp of it, I can finally dedicate my full attention to understanding container technologies. To start, I decided to focus on networking, which is the stack I'm most familiar with.
In this simple how-to guide, I'll walk you through observing the Address Resolution Protocol (ARP) in action within a Docker environment.
An Address Resolution Protocol(ARP) allows a container to learn the MAC address of another device (in this lab, it’s the bridge and other containers) dynamically.
Without an ARP, a ping between containers, external networks, or even a web request between containers and other devices fails.

.. toctree::
   :maxdepth: 2
   :caption: Table of Contents:

   pages/requirements
   pages/architecture-deployment-guide
   pages/view-packet-captures
   pages/clean-up
   pages/conclusion
   pages/resources