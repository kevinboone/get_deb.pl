## get\_deb.pl

This rather dirty Perl script downloads `.deb` packages and all their
dependencies -- recursively if necessary -- from a Debian 
repository and expands them into a selectable
staging directory (defaults to staging/rootfs). 

It is intended to do broadly the same job as `apt-get install`, but
on systems that don't have `apt-get`, don't want to install in the 
usual places, or need to download a foreign architecture. 

My main reason for writing this script is to use the contents of the
Raspbian repository for assembling custom Linux installations for the
Raspberry Pi. Of course, if you've got a running Pi, with a console and
a network connection, you can just run `apt-get` on the device; if you're
building a custom Linux for an embedded device, you don't have that
luxury. Of course it's easy enough to download the individual
<code>.deb</code> files and unpack them, but keeping track of all
the dependencies manually is a bear. Of course, the problem with
automatic dependency retrieval is that you can get a lot more
downloaded than you bargained for, especially when package maintainers
assume that everybody has unlimited disk space. There's no easy
solution to this problem.

The script takes a list of packages on the command line. The names
of these packages are exactly what you would supply to `apt-get`.
All other parameters, most obviously the base location of the repository
and the release name, are stored internally in the script -- I hope they
are reasonably easy to find.

The main index to the repository is a file called Packages, which is
generally huge (many tens of megabytes). The script downloads this
file if it does not exist in the current directory, and then does not
download it again, as it takes ages.

The code keeps track internally of what has been downloaded, to
avoid getting caught up in a dependency loop. However, there is no external
record of what has been downloaded, and nor is anything cached. Therefore, it
makes sense to specify as large a number of packages on the command line as
possible, to avoid duplicated downloads.

I would have thought that downloading from a 'foreign' repository like this was
a relatively common-place operation, and that the regular `apt-get` would be
able to do it. If it can, I can't figure out how.

At the time of writing, the latest Rasbpian release was 'Bookworm'.

