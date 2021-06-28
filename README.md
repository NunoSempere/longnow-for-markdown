This package takes a markdown file, and creates a new markdown file in which each link is accompanied by an archive.org link, in the format [...](original link) ([a](archive.org link)) 

## How to install
Copy [this file](https://github.com/NunoSempere/longNowForMd/blob/master/longnowformd.sh) to your .bashrc file, or, for Ubuntu distributions 20.04 (Focal Fossa) and above:

```
$ sudo add-apt-repository ppa:nunosempere/longnowformd
$ sudo apt-get update
$ sudo apt install longnowformd
```

This utility requires [archivenow](https://github.com/oduwsdl/archivenow) as a dependency, which itself requires a python installation. It can be installed with

```
$ pip install archivenow ## respectively, pip3
```

## How to use

```
$ longnow test.md
```
