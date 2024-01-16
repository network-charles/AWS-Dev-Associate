========
Clean-Up
========

Stop and Remove the Container
=============================
.. code-block:: bash

    # Stop containers alpine1 and alpine2
    docker stop alpine1 alpine2

    # Remove containers alpine1 and alpine2
    docker rm alpine1 alpine2

Delete Custom Bridge
====================
.. code-block:: bash

    # Remove custom_bridge network
    docker network rm custom_bridge

Verify Network List
===================
.. code-block:: bash

   root@ubuntu:/home/ubuntu# docker network ls
   NETWORK ID     NAME      DRIVER    SCOPE
   2eabde4e866c   bridge    bridge    local
   e9f54b21c605   host      host      local
   e9708605179a   none      null      local


Stop Ubuntu Server
===================

.. code-block:: bash

    # Stop Ubuntu server
    multipass stop ubuntu
