From: brian@worldcontrol.com
Date: Sat, 2 Sep 2000 11:50:32 -0700
Subject: Stuck at 1GB again
Message-ID: <20000902115032.A2764@top.worldcontrol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Some time ago, the list was very helpful in solving my programs
failing at the limit of real memory rather than expanding into
swap under linux 2.2.

Now my giant app is failing on a new limit.

I have an Athlon 850 with 2GB of RAM running 2.4.0-test7.

The kernel is compiled with the 4GB option. (which I think is
the 2/2GB option from 2.2.x kernels).  I believe the option is
supposed to assign 2GB of address space to real memory, and
2GB to virtual memory (from a per process point of view).

I've also compiled and am using glibc 2.2, though I believe
I don't need to in order to use up to 2GB of real memory.

Without glibc 2.2 I should be able to get to 2GB of memory
allocated via the heap.  I only need glibc 2.2 to start
mmap'ing malloc'able pools from VM. I.E. beyond 2GB of
malloc'ed memory.

My app running with 1 GB RAM under linux 2.2, with glibc 2.2
successfully malloc's up to 3GB and the app works fine. (though
swapping quite a bit).

My app running with 2 GB RAM under linux 2.4.0-test7, with glibc 2.2
dies at 1 GB of memory used.  (it also dies at 1 GB using glibc 2.1.2).

The app is compiled -static to make sure I get the right libraries.

I have an program which logs the memory usage of the application
from /proc.

These are logs from two runs that died very near the 1GB limit when
malloc returned an error:

967780380  986796 kB 0 kB  985216 kB  985636 kB 628 kB 508 kB    0 kB

967661675 1013092 kB 0 kB 1010700 kB 1011184 kB 540 kB 184 kB 1140 kB

Limits are set to:
cputime         unlimited
filesize        unlimited
datasize        unlimited
stacksize       8MB
coredumpsize    488MB
memoryuse       unlimited
maxproc         256
descriptors     1024
memorylocked    unlimited
addressspace    unlimited


Any idea what limit I'm running into?

-- 
Brian Litzinger <brian@litzinger.com>

    Copyright (c) 2000 By Brian Litzinger, All Rights Reserved
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
