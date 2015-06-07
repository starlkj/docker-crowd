# docker-crowd
Docker Atlassian Crowd



docker run -u root -v /data/crowd:/var/atlassian/application-data/crowd atlassian/crowd
chown -R daemon  /var/atlassian/application-data/crowd


sudo docker run -u root -v /data/crowd:/var/atlassian/application-data/crowd oranheim/crowd
sudo chown -R daemon  /var/atlassian/application-data/crowd

sudo docker run -it /data/crowd:/var/atlassian/application-data/crowd --name="crowd" -d -p 9001:9001 -p 9901:9901 oranheim/crowd

sudo docker stop crowd
sudo docker rm crowd



sudo docker build



sudo docker run -u root -v /data/crowd:/var/atlassian/application-data/crowd crowd chown -R daemon /var/atlassian/application-data/crowd

sudo docker run -v /data/crowd:/var/atlassian/application-data/crowd --name="crowd" -d -p 8095:8095 -p 9901:9901 crowd

