Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 598156B0070
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:55:51 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4Y007IV71WM8B0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:56:20 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4Y00E8M70YBJ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:55:46 +0100 (BST)
Date: Fri, 01 Jun 2012 18:54:38 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 3/3] proc: add pageblock size info to /proc/meminfo
Message-id: <201206011854.38232.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] proc: add pageblock size info to /proc/meminfo

Pageblock size info is not currently exported to user-space
while it is useful to know it when using with new /proc/kpagetype
interface.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 fs/proc/meminfo.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c	2012-05-31 16:29:47.107109613 +0200
+++ b/fs/proc/meminfo.c	2012-05-31 16:30:52.471109924 +0200
@@ -98,6 +98,7 @@ static int meminfo_proc_show(struct seq_
 		"VmallocTotal:   %8lu kB\n"
 		"VmallocUsed:    %8lu kB\n"
 		"VmallocChunk:   %8lu kB\n"
+		"PageblockSize:  %8lu kB\n"
 #ifdef CONFIG_MEMORY_FAILURE
 		"HardwareCorrupted: %5lu kB\n"
 #endif
@@ -156,7 +157,8 @@ static int meminfo_proc_show(struct seq_
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
 		vmi.used >> 10,
-		vmi.largest_chunk >> 10
+		vmi.largest_chunk >> 10,
+		K(pageblock_nr_pages)
 #ifdef CONFIG_MEMORY_FAILURE
 		,atomic_long_read(&mce_bad_pages) << (PAGE_SHIFT - 10)
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
