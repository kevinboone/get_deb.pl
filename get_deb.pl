#!/usr/bin/perl -w

use strict;

# Raspbian release
my $release = "buster";

# Relative directory where packages will be expanded
my $staging = "staging/rootfs";

# Base URL for the repository
my $base ="http://archive.raspbian.org/raspbian";

# Work out where the Packages file is for the specified distribution
my $remote_packages = "$base/dists/$release/main/binary-armhf/Packages";

# This is the local Packages file
my $packages = "Packages";

if (-f $packages)
  {
  print ("Local copy of Packages exists -- not downloading again\n");
  }
else
  {
  print ("Downloading $packages from $remote_packages\n");
  system ("curl -L -o $packages $remote_packages");
  }

my @downloaded_debs = ();

# If the package is found, returns a list with two elements --
#   the URL offset to the download in the repo, and the 
#   dependencies. Both are empty if the entry is not found. 
sub find_package_in_index ($)
  {
  my $found = 0;
  my $name = $_[0]; 
  my $rel_url = "";
  my $depends = "";
  open (PACKAGES, $packages) or die "Can't open $packages\n";
  while (<PACKAGES>)
    {
    my $line = $_;
    chomp ($line);
    if ($found)
      {
      if ($line)
        {

        if ($line =~ /Filename: (.*)$/)
          {
          $rel_url = $1;
          }
        if ($line =~ /Depends: (.*)$/)
          {
          $depends = $1;
          }
        }
      else
        {
        $found = 0;
        }
      }
    else
      {
      if ($line eq "Package: $name")
        {
        $found = 1;
        }
      }
    }
  close (PACKAGES);
  if ($rel_url)
    {
    return ($rel_url, $depends);
    }
  else
    {
printf ("returning empty\n");
    return ("", "");
    }
  }


sub download_deb ($)
  {
  my $rel_url = $_[0]; 
  my $url = $base . "/" . $rel_url;
  print ("url=$url\n");
  my $debfile = "temp.deb";
  system ("curl -L -o $debfile $url");
  if (-e $debfile)
    {
    system ("ar x $debfile");
    unlink ($debfile);
    if (-e "data.tar.xz") 
      {
      my $datafile = `realpath data.tar.xz`;
      chomp ($datafile);
      system ("cd $staging; xzdec $datafile | tar xvf - ");
      }
    elsif (-e "data.tar.gz") 
      {
      my $datafile = `realpath data.tar.gz`;
      chomp ($datafile);
      }
    else
      {
      print (".deb data file format not recognized\n");
      }
    unlink ("control.tar.gz");
    unlink ("control.tar.xz");
    unlink ("data.tar.gz");
    unlink ("data.tar.xz");
    unlink ("debian-binary");
    }
  else
    {
    print ("Error: can't download .deb file: $url\n");
    }
  }

sub get_package_and_dependencies ($);

sub get_package_and_dependencies ($)
  {
  my $name = $_[0]; 
  if (grep (/^$name$/, @downloaded_debs)) 
    {
    print ("Package $name already downloaded\n");
    }
  else
    {
    push (@downloaded_debs, $name);
    my @temp = find_package_in_index ($name);
    my $rel_url = $temp[0];
    my $depends = $temp[1];
    if ($rel_url)
      {
      system ("mkdir -p $staging");
      print ("Downloading $name from $rel_url\n");
      download_deb ($rel_url);
      if ($depends)
        {
        my @deps = split (',', $depends);
        foreach my $dep (@deps)
          {
          $dep =~ s/^\s+|\s+$//g;
          $dep =~ /(\S*)/;
          $dep = $1;
          printf ("Downloading dependency $dep\n");
          get_package_and_dependencies ($dep);
          }
        }
      }
    else
      {
      print ("Package $name has no offset URL -- is it in the index?\n");
      }
    }
  }


for (my $i = 0; $i < scalar (@ARGV); $i++)
  {
  get_package_and_dependencies ($ARGV[$i]);
  }



