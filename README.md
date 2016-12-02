# About
Ragent is am agent framework. It's meant to be installed on a host and connect do it's jobs.
It's exact job depends on the plugins you install.
Available plugins are:
 * master - a master node that receives data
 * slave - a slave node that send data
 * docker-events
 * docker-control
 * stats

# Usage


ragent start <directory> --commands [<command file>] --master [user:password@hostname:port]

If the command file is given it will read and execute the commands.

If the master is given (hostname:port) the agent connects and is waiting for commands.

ragent connect <directory>
connect to a local running agent


The master node has to install the "master" plugin.

Built in commands

plugin install <name> <git repo>
plugin uninstall <name>
plugin list
logger stdout
logger file <file>
logger level <debug|info|warning>
