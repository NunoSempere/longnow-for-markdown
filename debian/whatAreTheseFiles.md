These files outline how to place the longnow file in the `/usr/bin` directory with the adequate permissions, for each of the last several Ubuntu releases. 

Because doing so is incredibly redundant (partly because I'm using a cannon to kill a mosquito), I can automate this process using the createSeries.sh utility. Doing it this ways means that people can install the repository using 
```
$ sudo add-apt-repository ppa:nunosempere/longnowformd
$ sudo apt-get update
$ sudo apt install longnowformd
```
