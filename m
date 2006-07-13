Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6DHFMQa029829
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 13 Jul 2006 13:15:22 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6DHFMGa276772
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 13 Jul 2006 13:15:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6DHFM5A023324
	for <linux-mm@kvack.org>; Thu, 13 Jul 2006 13:15:22 -0400
Subject: [PATCH] update /proc/meminfo Buffers documentation
From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 13 Jul 2006 10:15:17 -0700
Message-Id: <20060713171517.8B324CD3@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: pbadari@us.ibm.com, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The filesystems/proc.txt meminfo documentation is a wee bit inaccurate
with respect to buffers.  They can get a bit bigger than 20MB, and I have
proof ;).  I copied a description that Badari gave me on IRC for this
patch.

$ cat /proc/meminfo
MemTotal:     16375148 kB
MemFree:       9372524 kB
Buffers:        818276 kB
Cached:        4923044 kB
SwapCached:          0 kB
Active:        3517596 kB
Inactive:      2437724 kB
HighTotal:    14548952 kB
HighFree:      9355304 kB
LowTotal:      1826196 kB
LowFree:         17220 kB
SwapTotal:    32611940 kB
SwapFree:     32610724 kB
Dirty:            5932 kB
Writeback:           0 kB
Mapped:         231172 kB
Slab:           977396 kB
CommitLimit:  40799512 kB
Committed_AS:  1373664 kB
PageTables:       7412 kB
VmallocTotal:   116728 kB
VmallocUsed:     16408 kB
VmallocChunk:   100104 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     2048 kB


---

 lxc-dave/Documentation/filesystems/proc.txt |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -puN Documentation/filesystems/proc.txt~update-meminfo-documentation Documentation/filesystems/proc.txt
--- lxc/Documentation/filesystems/proc.txt~update-meminfo-documentation	2006-07-13 10:07:18.000000000 -0700
+++ lxc-dave/Documentation/filesystems/proc.txt	2006-07-13 10:07:19.000000000 -0700
@@ -389,8 +389,9 @@ VmallocChunk:   111088 kB
     MemTotal: Total usable ram (i.e. physical ram minus a few reserved
               bits and the kernel binary code)
      MemFree: The sum of LowFree+HighFree
-     Buffers: Relatively temporary storage for raw disk blocks
-              shouldn't get tremendously large (20MB or so)
+     Buffers: Relatively temporary storage for raw disk blocks.  Also
+	      used for caching filesystem metadata (like directories,
+	      indirect blocks, inode maps, block maps etc..).
       Cached: in-memory cache for files read from the disk (the
               pagecache).  Doesn't include SwapCached
   SwapCached: Memory that once was swapped out, is swapped back in but
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
