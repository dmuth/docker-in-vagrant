
# Docker in Vagrant

<img src="./img/logo.png" align="right" width="250" />

This project lets you deploy Docker inside of a Vagrant VM in Virtualbox.

It is intended as a replacement for Docker Desktop for Mac OS/X users.  I've tested it with some of my open source projects, including [FastAPI Httpbin](https://github.com/dmuth/fastapi-httpbin) and [Grafana Playground](https://github.com/dmuth/grafana-playground).  I'd like to think it's bug-free, but if there are any issues, my contact info is at the bottom of this README.


## Prerequisites

- [Docker CLI tools](https://formulae.brew.sh/formula/docker)
- [Virtualbox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- [Pipeviewer](https://catonmat.net/unix-utilities-pipe-viewer)
  - This is used for watching progress.  Install with `brew install pv`.
- `ssh-agent` should be setup


## Features

- Easily spin up a VM with Docker already installed and running, using `bin/start.sh`.
- Packages installed via `yum` will be cached to disk outside of the VM, making future builds less network intensive.
- Sshd is configured to support up to 100 sessions to speed up operations with `docker-compose`.
- Docker images can be saved to disk outside the VM with `docker-save-images.sh`.
- Docker images will be automatically loaded from disk outside the VM at startup with `docker-load-images.sh`.


## Installation

- Clone this repo
- Run the script `./bin/start.sh` to start the VM.
  - This will also configure the VM so that Docker is installed and can be run as a non-root user, SSH is set up to accept more simultaenous connections, etc.
- The script will prompt you to do this, but you should add the SSH key to your agent by putting something like this inside your `.bashrc` or similar:
  - `export DOCKER_HOST=ssh://vagrant@127.0.0.1:2222"`
- The script will also prompt you to add configuration to `$HOME/.ssh/config` so you can connect to the VM without being prompted for a password, dealing with SSH key issues, or getting "this host key has changed" warnings.
- Finally, the script will display a line for you to include in `$HOME/.bashrc` to set aliases for interacting with the Docker VM.  One of them will be `docker-aliases`, which will print out those aliases.

When the above steps are done, you can now run commands like `docker ps` natively in OS/X,
they will be sent to the Docker daemon running in the VM over SSH, and results will be returned.


## Development

If you've set up the suggested aliases, they'll make development simpler.  Here are a few things
I like to use:
- `docker-destroy; docker-start` - Blow away and build a new VM
- `docker-check-time` - Check the system time versus the VM time.  Run `docker-restart` if they've fallen out of sync.
- `docker-ssh` - Open an SSH connection to the VM.


### Other Useful Utilities

- `bin/status.sh` - Reports back the status of the VM
- `bin/start.sh` - Already covered, this starts up the VM and loads the SSH key.
- `bin/restart.sh` - Restart the VM.  Will not start it if stopped.
- `bin/stop.sh`  - This stops the VM temporarily.
- `bin/destroy.sh` - This destroys the VM.
- `bin/docker-load-images.sh` - This loads Docker images which were saved outside of the VM. Used by `start.sh`.
- `bin/docker-save-images.sh` - Save existing Docker images outside of the VM. Run manually.
- `bin/provision.sh` - Run the `vagrant provision` command.  Optional environment variables to speed up testing and debugging include:
  - `SKIP_APT`, `SKIP_DOCKER`, `SKIP_SSH`, and `SKIP_TIME`.


## Frequently asked questions

### FAQ: You get a "Permission denied (public key)" error when trying to use a Docker command.

Did you add the key to `ssh-agent`?  If so, did you destroy and rebuild the instance?  You'll need to re-add the key since a new SSH key was generated as part of that process.


### FAQ: Sometimes when using docker-compose on a bunch of containers at once, I see an SSH error!

I am trying to reproduce this reliably, but it seems that this happens when sshd gets too many incoming connections at once!  If it does happen to you, just run the command again.  Docker commands such as `up` and `kill` are idempotent, so running them more than once should not cause any harm.


### FAQ: I get an error saying "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

It's all good--it means you have a reference to the VM sitting in your `$HOME/.ssh/known_hosts` file.
Take a look through that file and see if you see any lines that start with `[127.0.0.1]:2222` or similar.
The tell is the `2222`, which is the port that Vagrant hosts listen on.  Delete those lines manually 
or with this command:

`sed -i -e '/\[127.0.0.1\]:2222/d' ~/.ssh/known_hosts`

Note that the script `bin/start.sh` should do this automatically, and you should only have to
do this if something has gone wrong.


### FAQ: I get an error that says "Cannot connect to the Docker daemon" or similar!

If the VM is running, did you tell the Docker CLI tools about it?  You can do so on the command
line with something like this:

`export DOCKER_HOST=ssh://vagrant@127.0.0.1:2222`


### FAQ: I run a command like docker-compose and some containers start, but I still get SSH errors?

If you are trying to do stuff with many containers at once, you may need a higher [MaxStartups value](https://stackoverflow.com/questions/4812134/in-sshd-configuration-what-does-maxstartups-103060-mean) in `/etc/ssh/sshd_config`.  By default it is set to `100:30:100`, which should handle most cases, but if the value needs to be increased, just be sure to run `systemctl restart sshd` after doing so.


### FAQ: Are there bugs?

Unfortunately, yes.  There seem to be some low-level filesystem issues that trip up a few things.  In detail:


### FAQ: Splunk Lab Issues

Yeah I know this isn't a question.

I tried spinning up an instance of [Splunk Lab](https://github.com/dmuth/splunk-lab), and saw no logs making it into Splunk and plenty of these errors:

```
11-15-2022 01:45:31.042 +0000 ERROR StreamGroup [217 IndexerTPoolWorker-0] - failed to drain remainder total_sz=24 bytes_freed=7977 avg_bytes_per_iv=332 sth=0x7fb586dfdba0: [1668476729, /opt/splunk/var/lib/splunk/_internaldb/db/hot_v1_1, 0x7fb587f7e840] reason=st_sync failed rc=-6 warm_rc=[-35,1]
```

I am still troubleshooting this.


### Httpbin Issues

I know this isn't a question either.

My [FastAPI Httpbin project](https://github.com/dmuth/fastapi-httpbin) doesn't behave right when
run in development mode in a Docker container spawned by this app.  Specifically, the functionality
of FastAPI to reload itself when a file is changed does not seem to work.  For now, the workaround
is to restart the FastAPI server when new changes are to be tested, or to not run it in a container 
in the first place.

Production use is unaffected.


## Get In Touch

If you run into any problems, feel free to [open an issue](https://github.com/dmuth/docker-in-vagrant/issues).

Otherwise, you can find me [on Twitter](https://twitter.com/dmuth), [Facebook](https://facebook.com/dmuth), or drop me an email: **doug.muth AT gmail DOT com**.



