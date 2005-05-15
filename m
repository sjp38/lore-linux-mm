Date: Sun, 15 May 2005 13:00:36 +1000
From: Anton Blanchard <anton@samba.org>
Subject: NUMA API on ppc64 issues
Message-ID: <20050515030036.GB5829@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de
List-ID: <linux-mm.kvack.org>

Hi,

I tried running the NUMA API on a ppc64 box (version numactl-0.7pre2, I 
hope thats the latest). I noticed is that the cpu affinity code is not
endian safe. Watching a 64bit version of numademo:

19206 sched_setaffinity(19206, 64,  { 300000000, 0, 0, 0, 0, 0, 0, 0 }) = -1 EINVAL (Invalid argument)

...

19206 sched_setaffinity(19206, 64,  { f000000000000, 0, 0, 0, 0, 0, 0, 0 }) = -1 EINVAL (Invalid argument)

Whereas my cpumask is 000000000000f003 - its swapping the two 32bit
words. Looks like numa_node_to_cpus needs some work to be endian safe.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
