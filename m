Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA07921
	for <linux-mm@kvack.org>; Fri, 12 Jun 1998 01:06:25 -0400
Subject: shmfs-0.1.009 & shmfs-0.3.001 are available
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 12 Jun 1998 00:00:25 -0500
Message-ID: <m11zsv5i52.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: SHMFS list <ebiederm+shmfs@npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


When pondering how to add POSIX.4 shared memory areas to linux it
occured to me that probably the easiest way would be just to implement
a simple filesystem, and code into libc in which directory to look.

It also occured to me this would be a good opportunity to work on
adding dirty page support to the page cache code and I have done that
as well.

The quick synopsis of what I have written is as follows:
A complete filesystem that resides in swap, and for kicks and reduced
  space consumption uses a btree for all of it's directories.
A patch to allow the page cache to handle dirty files
A patch to allow the swapoff to work with swap pages that do not
  reside in page tables.  
  SYSV shared memory has been modified to work with this, fixing a
  really old/rare swapoff bug.
A patch to allow asynchronous I/O to swapfiles.

This is an beta release, aimed at producing a stable version shortly.

My code is at:
http://www.npwt.net/~ebiederm/files/
files:
shmfs-0.1.009.tar.gz shmfs-0.3.001.tar.gz

shmfs-0.3.001 is a developmental version written primarily by 
Gabor Kuti <seasons@falcon.sch.bme.hu> where new features are being
worked upon.  Since I just started integrating his patches I may have
done something stupid...

shmfs-0.1.009 has hit the code freeze before becoming shmfs-0.2.000
a stable and usefull version.  Strange interactions with kernel memory
management are the only things left before 0.2

This works with both kernels 2.0.32 and 2.1.101.  
2.1.102-2.1.105 should also work but I haven't tested those.
2.0.32 support is almost necessary so I can tell my bugs from, those
of others :)

Changes since 0.1.008:
Fixed minor bugs and ported to kernel 101.  Now I should have a
correct kernel patch, on a kernel that handles swapping correctly.
Use on development kernels is no longer discouraged, only minor
performance glitches appear to remain as problems there.

Changes since 0.1.004:
I have synchronized my two versions, and rewritten a bunch of namei
code in the search for races.  And I have found and fixed my
mysterious mutating symlink bug.

Eric
