# get\_deb.pl

Version 0.2, February 2023

Copyright (c) Kevin Boone, 2018-2023. Distributed under the terms of the
GPL, v3.0.

## What is this?

This rather dirty Perl script downloads `.deb` packages and all their
dependencies -- recursively if necessary -- from a Debian repository and
expands them into a selectable staging directory. I use it as part of the
process of building custom Linux installations for the Raspberry Pi. It is not,
in principle, limited to use with Raspberry Pi, but that's all I've tested.
With this utility, I can assemble a complete root filesystem image on a Linux
workstation, and copy it to an SD card for use in the Pi.

Of course, if you've got a running Pi, with a console or a network connection,
you can just run `apt-get` on the device; if you're building a custom Linux for
an embedded device, you don't have that luxury. Of course it's easy enough to
download the individual <code>.deb</code> files and unpack them, but keeping
track of all the dependencies manually is a bear. Of course, the problem with
automatic dependency retrieval is that you can get a lot more downloaded than
you bargained for, especially when package maintainers assume that everybody
has unlimited disk space. There's no easy solution to this problem.

The script caches what it can, to reduce the amount of repated downloading
required when running it repeatedly. After all, many packages have the same
common dependencies. It's important to understand, however, that downloading is
not really the limiting factor on script's speed of execution.

I would have thought that downloading from a 'foreign' repository like this was
a relatively common-place operation, and that the regular `apt` utility would be
able to do it. If it can, I've never been able to figure out how.

## Usage

The script takes a list of packages on the command line, and reads a number of
environment variables that control how it works. The names of these packages
are exactly what you would supply to `apt-get`.  Some other parameters, most
obviously the base location of the repository, are stored internally in the
script -- I hope they are reasonably easy to find, because they can't be
configured except by changing the script.

The code keeps track internally of what has been downloaded, to avoid getting
caught up in a dependency loop. 

I presume that this script will work with repositories other than those for the
Raspberry Pi, but it will be necessary to hack the repository's base URL in the
script.

## Environment variables

The script reads the following environment variables, which *must* be
set, or it will fail in unhelpful ways.

`ROOTFS` -- the directory to which packages will be expanded. This will be 
essentially an image of the root filesystem.

`TMP` -- the temporary directory. This script itself does not use this,
but some tools it invokes might do.

`RASPBIAN_RELEASE` -- the name of the release: buster, bullseye, etc.
At the time of writing, the latest Rasbpian release was 'Bullseye'.


`CACHEDIR` -- directory in which to cache the downloaded .deb files

Please note that, if you're download a lot of packages, or packages with
extensive directories, then extensive space will be used in the 
`ROOTFS` and `CACHEDIR` directories. 

## Notes

`get_deb.pl` downloads from the 'main' and 'non-free' categories of the
repositories. It would be reasonably easy to add other categories, but I have
never needed them.

The script writes files to the current directory, which must therefore be
writeable. It cleans up afterwards, but it's difficult to change this
behaviour. 

At present, the main limitation on speed is searching the index for
dependencies. The index file is enormous, and it's just plain ASCII text.  A
better approach would be to parse this file once at start-up, and build in the
cache a list of packages and their dependencies, in a format that is quick to
read. 

## Author and legal

`get_deb.pl` is copyright (c)2018-2023 Kevin Boone, and distributed under the
termins of the GNU Public Licence, v3.0. In short: you are free to use, modify,
and distribute it, but there is no warranty of any kind. 





