Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 3E1BA6B006C
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:55:50 -0400 (EDT)
Received: from euspt1 (mailout4.w1.samsung.com [210.118.77.14])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4Y00HDX726TEB0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:56:30 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4Y001WT710ZP@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:55:48 +0100 (BST)
Date: Fri, 01 Jun 2012 18:54:17 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 2/2] proc: add ARCH_PFN_OFFSET info to /proc/meminfo
Message-id: <201206011854.17399.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] proc: add ARCH_PFN_OFFSET info to /proc/meminfo

ARCH_PFN_OFFSET is needed for user-space to use together with
/proc/kpage[count,flags] interfaces.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 fs/proc/meminfo.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c	2012-05-31 16:53:11.589706973 +0200
+++ b/fs/proc/meminfo.c	2012-05-31 17:03:17.719237120 +0200
@@ -168,6 +168,10 @@ static int meminfo_proc_show(struct seq_
 
 	hugetlb_report_meminfo(m);
 
+	seq_printf(m,
+		"ArchPFNOffset:    %6lu\n",
+		ARCH_PFN_OFFSET);
+
 	arch_report_meminfo(m);
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
