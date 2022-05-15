# Installing Minecraft 1.18.2 (java) server to ubuntu by using salt state.

In this project a Minecraft server is installed to ubuntu by using salt state. This is the school project and the final work of the course.

In the course we have learned how to use salt state. Personally, I have had to learn more. I just couldn’t use Linux before the course, let alone servers or salt.
So the starting point was not very good. However in doing this task, I found myself understanding several things I didn’t know before the course began. I also learned to use several different salt state commands. The hardest part was coming up with a suitable topic for my work. I went through several different options and ran into problems at the beginning. For example, Obs-studio does not work through the VirtualBox that was originally intended to be installed. Eventually, I came up with a topic and spent several hours preparing to browse related videos and articles on the internet. I try to gather all possible information to make the installation a success and the server up and running.

----------

The test, installation and "project" has been done with **Ubuntu 21.10**, which I run with **VirtualBox**.

### Preparation: 
Before this project I have already installed a salt master and a salt minion called Teronapuri (Teroshelper).
I made directory for project `/srv/salt/MCS` so this is where all files goes. I also made `init.sls` (salt state file) there. So if you want try this project make that directory and copy my init.sls there. 

You need:
1. salt master/minion
2. /srv/salt/MCS folder
3. init.sls file
4. working internet

---------------

## -START-
Before creating a salt state, we need to find out what we need to make the Minecraft server working. 

Fortunately, a lot of information about this can be found on the internet. The first thing to keep in mind is java support. We need the latest possible java version to get the latest java based Minecraft server up and running. I personally used this page to help https://minecraft.fandom.com/wiki/Tutorials/Setting_up_a_server

So we need to have **Openjdk** version **18** installed (I tried version 16, it is not compatible)

In addition to this, we need **Curl** in order to upload the Minecraft server file.

+ extra: We download **Byobu**, so we can run the server in byobu and the shell is still available at the same time.

All of these we find using the Advanced Packaging Tool - APT

we tell the salt minion to install these programs (openjdk-18-jdk, byobu and curl)
```
$ /srv/salt/MCS/init.sls
install java:
  pkg.installed:
    - name: openjdk-18-jdk
     
install byobu:
  pkg.installed: 
    - name: byobu
     
install curl:
  pkg.installed:
    - name: curl
```

-----------------------

The foundation has now been laid. We have java support, we have curl and we have byobu. Next, we download the Minecraft server file itself. The file could either be downloaded using a browser or, as in this case, using salt.

```
download server file: 
  cmd.run:
    - name: curl https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar --output /srv/salt/MCS/server.jar
    - creates: /srv/salt/MCS/server.jar
```
`curl` command loads `server.jar` from that path. The `--output` option specifies the path and file name. In this case, the file is uploaded to the `/srv/salt/MCS/` folder named `server.jar`. The file path is from the official Minecraft websites.

-------------------------
Next, we need to create an **End User License Agreement** = `EULA` approval. So let's tell salt to make a file called `eula.txt` and the contents of the file: `eula = true` (without this the server will not start.)

```
eula=true file:
  file.managed:
    - name: /srv/salt/MCS/eula.txt
    - contents: 
      - eula=true
```
Now we should have everything we need installed, created and downloaded. 

Let's change the ufw settings and make a hole in the 25565/tcp port so that the friends can also join the server. Minecraft normally uses that 25565 port. (Also we make sure ufw (firewall) is on.)

```
ufw allow 25565:
  cmd.run:
    - unless: "ufw status verbose | grep '25565/tcp'"

ufw enable:
  cmd.run:
    - unless: "ufw status | grep 'Status: active'"
```

---------------------

Now we should have all the necessary base work done and one can move on to see what our salt state looks like and does it work?


## Salt state - init.sls









Lets test our salt state! 
![image](/.attachments/af06dd37017a1131bd1f54d41abd0770994bf9e7.png)
All pkg.installed functions works. Because they were not installed salt installed them.
