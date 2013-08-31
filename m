Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 113256B0032
	for <linux-mm@kvack.org>; Sat, 31 Aug 2013 19:15:06 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1VFuNj-0001XU-Hv
	for linux-mm@kvack.org; Sun, 01 Sep 2013 01:15:03 +0200
Received: from dagmar1.corp.linkedin.com ([69.28.149.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 01 Sep 2013 01:15:03 +0200
Received: from cuonghuutran by dagmar1.corp.linkedin.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 01 Sep 2013 01:15:03 +0200
From: Cuong Tran <cuonghuutran@gmail.com>
Subject: Why did I see isolated file/anon when system has high pgscand/s and 16 GB free memory
Date: Sat, 31 Aug 2013 23:13:40 +0000 (UTC)
Message-ID: <loom.20130901T005903-258@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi, my apology if this question is to the wrong group but I think this is
teh group most qualified to explain the cause of the problem I saw.

Basically our application uses about 5 GB heap space (JVM), which
memory-maps about 1500 files, 100 MB, for total of 15 GB. The files are
read-mostly and many pages can be inactive.

The server runs RedHat 2.6.32-220.10.1.el6.x86_64, has 2 CPUs, 24 cores
including hyper-threading.
It has about 48 GB and thus plenty of free memory as shown meminfo output
below.   swappiness is set to 0. Other Linux kernel tunings are by default
from RH.

We ran into very intense pgscand/s even if free memory is 16 GB and we
correlated it with counts of isolated files/anon. Needless to say, when this
happens, our app slows down considerable. 

We would be grateful if you could explain what happened and what settings we
should apply. 

Thank you in advance,

Output of meminfo below:

MemTotal:       49358752 kB
MemFree:        16098532 kB
Buffers:          335788 kB
Cached:         26414224 kB
SwapCached:            0 kB
Active:          6444192 kB
Inactive:       25673036 kB
Active(anon):    5366776 kB
Inactive(anon):      840 kB
Active(file):    1077416 kB
Inactive(file): 25672196 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:      16776116 kB
SwapFree:       16776116 kB
Dirty:               260 kB
Writeback:             0 kB
AnonPages:       5366888 kB
Mapped:         17348504 kB
Shmem:               372 kB
Slab:             530388 kB
SReclaimable:     466752 kB
SUnreclaim:        63636 kB
KernelStack:        8864 kB
PageTables:        55844 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    61198992 kB
Committed_AS:    8475504 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      383776 kB
VmallocChunk:   34332638712 kB
HardwareCorrupted:     0 kB
AnonHugePages:   4958208 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:        4676 kB
DirectMap2M:     2027520 kB
DirectMap1G:    48234496 kB




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
