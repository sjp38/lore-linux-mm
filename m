Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA18057
	for <linux-mm@kvack.org>; Mon, 29 Jun 1998 19:39:56 -0400
Subject: SHMFS-0.1.010 is released.
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 29 Jun 1998 18:47:37 -0500
Message-ID: <m11zs7ahye.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: SHMFS list <shmfs@flinx.npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This is an beta release, aimed at producing a stable version shortly.

My code is at:
http://www.npwt.net/~ebiederm/files/
files:
shmfs-0.1.010.tar.gz shmfs-0.3.001.tar.gz

shmfs-0.3.001 is a developmental version written primarily by 
Gabor Kuti <seasons@falcon.sch.bme.hu> where new features are being
worked upon.  Since I just started integrating his patches I may have
done something stupid... 

shmfs-0.1.010 has hit the code freeze before becoming shmfs-0.2.000
a stable and usefull version.

For people wishing to look at what I have done with dirty pages in the
page cache, this should be a good release to look at.  I still need to
document it more but working code, and clean patches is should be good
enough if you know the linux-kernel :)

This works with both kernels 2.0.32 and 2.1.101.  
2.1.102-2.1.105 should also work but I haven't tested those.

Changes since 0.1.009:
Rewrote the kernel patches, and modified shmfs to take advantage of
the new semantics.  With this version shmfs on linux-2.1.101 has
become quite useful.

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
