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

+ extra: We download **Byobu**, with Byobu we can make an extra shell window to start the server. For this reason, we can use shell normally even when the server is running. Otherwise, the server would use shell itself until we shut it down. 

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
This is what it looks like now. Salt state which downloads the necessary programs, installs them, loads the server.jar file, creates an eula.txt file and changes the ufw settings.
![](https://cdn.discordapp.com/attachments/784040982043295814/975466582316834946/unknown.png)







Lets test our salt state! 
![image](/.attachments/af06dd37017a1131bd1f54d41abd0770994bf9e7.png)
All pkg.installed functions works. Because they were not installed salt installed them.
![image](/.attachments/bef879f12705f3c2090ffd1f099ce3143f5ecb3c.png)
Server.jar downloaded successfully and the eula.txt file was created correctly.
![image](/.attachments/efeecc2256e8d47178085fd588e45deb303e8927.png)
Ufw changes were successful and ufw is on. It took almost 40 seconds due to downloads and installations. Now, however, everything should be ready!

Let's try again and see if there will be idempotence or if there are problems in the salt state.
![image](/.attachments/309b973ea42ed2383fe92a2edc7000aad309099c.png)
Again, all functions work. The programs were installed in the previous run of the salt state, so now minion don't have to touch them and can move on.
![image](/.attachments/5c6642cc5d657372bea7a8bd65390a927dc5272c.png)
Since server.jar is already downloaded, the minion is understood that the file does not need to be reloaded. Similar to the eula.txt file, the file exists. No need to make new ones.
![image](/.attachments/e9d6ba7458f76c0dbeba2dc507e1e81596366a1a.png)
  
Also, the change that was made to ufw has been noticed and does not need to be made again. ufw is also confirmed to be on. 
So everything should work in salt state, all that's left is to try the server itself, will it work? Is it going to work?

-------------

## Server
Lets try to start the server with the following command:
```
sudo java -Xms1024M -Xmx1024M -jar /srv/salt/MCS/server.jar --nogui
```
Java options should be added between the `java` and the `-jar`.
`-Xms` (the initial memory size).
`-Xmx` sets how much memory the server is allowed to use.
`/srv/salt/MCS/server.jar` is the server location and file.
`--nogui` Doesn't open the GUI when launching the server.
You can also set other parameters at the start command, more instructions can be found at this link:
https://minecraft.fandom.com/wiki/Tutorials/Setting_up_a_server

![image](/.attachments/fd259946c462d40e9d02d34b769ae043e6265453.png)
So server is started and running
![image](/.attachments/f2e50820311da67f3ef7e961e799b4f283cc47ab.png)


I also started the server using the graphical user interface.
![image](/.attachments/32733eef6fbf816859c526f22ff52b94288776e8.png)

## The end

Unfortunately, even if I get the server to run and stay running it stays there. The biggest problems accessing the server can be found between the virtual machine -> windows and the windows -> router. In order to be able to access the server running on the virtual machine, a port forward should be created throughout the whole line. Because microsoft has made it impossible to download the trial version of the game (watch reviews from microsoft market), I'll leave the adjustment to this point. I don't own that game, and I'm not going to pay 26 euros for it because of the course. So in order for the server to be able to join and play, there would be even more adjustments still to be made. However, setting up a server was a good exercise for myself and I learned a lot from it. At the same time, I think I was able to create a successful module.



Sources:

- MinecraftWiki: Tutorials/Setting up a server. https://minecraft.fandom.com/wiki/Tutorials/Setting_up_a_server
- Pezet, Don 2021: How to install a Minecraft Server on Linux - Ubuntu. https://www.youtube.com/watch?v=Yxi_If6JGTQ
- DOWNLOAD THE MINECRAFT: JAVA EDITION SERVER. https://www.minecraft.net/en-us/download/server
- CURL: Command line tool and library for transferring data with URLs. https://curl.se/
- Byobu. https://www.byobu.org/
- Karvinen, Tero 2020: Command Line Basics Revisited. [https://terokarvinen.com/2020/command-line-basics-revisited/](https://terokarvinen.com/2020/command-line-basics-revisited/)
- SaltStack 2016: Functions. ([https://docs.saltproject.io/en/getstarted/config/functions.html](https://docs.saltproject.io/en/getstarted/config/functions.html))
- Karvinen, Tero 2022: Configuration management systems 2022. [https://terokarvinen.com/2021/configuration-management-systems-2022-spring/](https://terokarvinen.com/2021/configuration-management-systems-2022-spring/)
