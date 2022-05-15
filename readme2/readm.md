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