Date: Tue, 13 Dec 2005 22:20:35 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] Fix calculation of grow_pgdat_span() in mm/memory_hotplug.c
Message-Id: <20051213220842.9C02.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave-san.
CC: Andrew-san.

I realized 2.6.15-rc5 still has a bug for memory hotplug.
The calculation for node_spanned_pages at grow_pgdat_span() is
clearly wrong. This is patch for it.

(Please see grow_zone_span() to compare. It is correct.)

Thanks.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: zone_reclaim/mm/memory_hotplug.c
===================================================================
--- zone_reclaim.orig/mm/memory_hotplug.c	2005-12-13 21:38:16.000000000 +0900
+++ zone_reclaim/mm/memory_hotplug.c	2005-12-13 21:39:14.000000000 +0900
@@ -104,7 +104,7 @@ static void grow_pgdat_span(struct pglis
 		pgdat->node_start_pfn = start_pfn;
 
 	if (end_pfn > old_pgdat_end_pfn)
-		pgdat->node_spanned_pages = end_pfn - pgdat->node_spanned_pages;
+		pgdat->node_spanned_pages = end_pfn - pgdat->node_start_pfn;
 }
 
 int online_pages(unsigned long pfn, unsigned long nr_pages)

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
