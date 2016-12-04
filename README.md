# About
Ragent is am agent framework. It's meant to be installed on a host and do it's jobs.
It's exact job depends on the plugins you install.

Available plugins are:
 * master - a master node that receives data
 * slave - a slave node that send data
 * stats - cpu, hd, ....

# Usage


ragent start <directory>
start the agent and all plugins

ragent connect <directory>
connect to a local running agent

Built in commands

plugin install <name> <url>
plugin uninstall <name>
plugin list
plugin start <name>
plugin stop <name>
plugin config <name>

logger stdout
logger file <file>
logger level <debug|info|warning>

# FAQ

Why doesn't it daemonize. We'll leave this problem to docker or daemonize and other similar tools.


# TODO
 * dependency resolution
 * dependency versioning
 * connect
