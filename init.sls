install java:
  pkg.installed:
    - name: openjdk-18-jdk
     
install byobu:
  pkg.installed: 
    - name: byobu
     
install curl:
  pkg.installed:
    - name: curl

download server file: 
  cmd.run:
    - name: curl https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar --output /srv/salt/MCS/server.jar
    - creates: /srv/salt/MCS/server.jar
    
eula=true file:
  file.managed:
    - name: /srv/salt/MCS/eula.txt
    - contents: 
      - eula=true
      
ufw allow 25565:
  cmd.run:
    - unless: "ufw status verbose | grep '25565/tcp'"

ufw enable:
  cmd.run:
    - unless: "ufw status | grep 'Status: active'"
