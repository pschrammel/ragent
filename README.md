# About
Ragent is am agent framework. It's meant to be installed on a host and do it's jobs.
It's exact job depends on the plugins you install.

Available plugins are:
 * master - a master node that receives data
 * slave - a slave node that send data
 * stats - cpu, hd, ....

# Usage


ragent <directory>
start the agent and all plugins

Built in commands

 * help
 * shutdown




# FAQ

Why doesn't it daemonize. We'll leave this problem to docker or daemonize and other similar tools.


# TODO
 * dependency resolution
 * dependency versioning
 * connect
 * plugins
   * websocket (endpoint)
