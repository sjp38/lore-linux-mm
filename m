Date: Fri, 30 Aug 2002 17:54:09 -0400
Mime-Version: 1.0 (Apple Message framework v482)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Subject: Avoiding the highmem mess
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Message-Id: <0334AD85-BC63-11D6-B00B-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Folks,

As I've mentioned before, I'm trying to do some basic experiments using 
the Linux VM.  Part of doing these experiments will involve reverting the 
kernel to a more ``classic'' kind of structure:  A SEGQ layout where the 
active pages are managed by a CLOCK algorithm, and the inactive pages are 
kept in an LRU queue and are marked ``not present'' so that references to 
them generate a trap.  Critically, I don't aim to produce a kernel that 
will work on non-x86 platforms, let alone NUMA machines or even (at least 
initially) multiprocessor machines.  I want to do some experiments where 
the heart of the matter lies in testing single-processor management.  
(Back to basics!)

SO!  To that end, I'd like to avoid the ZONE_HIGHMEM mess.  It seems oddly 
done, and creates new kinds of contention between pools of pages that I 
don't want polluting my experiments.  (That's not to say that I don't 
think it's a problem worth solving -- it's just not *the* problem that *I*
  want to examine just yet.)

Is there an easy way to avoid ZONE_HIGHMEM?  Is it as easy as avoiding 
machines that have more than 1 GB of physical memory so that only 
ZONE_NORMAL is used?  I'd be happy to just use ZONE_NORMAL (and ZONE_DMA, 
which I'm not all that worried about here) and have my experimental code 
fail to support machines with more than 1 GB.  Later I may want to fix 
that, but I need to start with something simple and comprehensible.

Tips?  Feedback?  Your commentary is greatly appreciated...
Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9b+mE8eFdWQtoOmgRAtVbAJ45HVBGz6BsDAEaoMQ8sDPSIIUtlACgjNFX
V7wxeT5NNPfS4KDmlqJbsIM=
=B0NR
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
