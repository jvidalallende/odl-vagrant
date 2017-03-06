ODL-VAGRANT
===========

The goal of this project is providing a vagrant-based development environment
for OpenDaylight, more specifically, for the Service Function Chaining (SFC)
project of ODL.

Taking as a base box Ubuntu 16.04 Xenial Xerus, this project does:

 - Resize the hard disk associated to the box to 50GB
 - Install OpenVSwitch 2.6.1 with NSH support
 - Install git, java, maven, and some other development tools
 - Clone several OpenDaylight repositories
