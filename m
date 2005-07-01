Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j620X1ZC017239
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 17:33:01 -0700
Date: Fri, 1 Jul 2005 15:41:48 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224148.542.16187.51386@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 11/11] mm: manual page migration-rc4 -- N1.2-add-nodemap-to-try_to_migrate_pages-call.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Manual page migration adds a nodemap arg to try_to_migrate_pages().
The nodemap specifies where pages found on a particular node are to
be migrated.  If all you want to do is to migrate the page off of
the current node, then you specify the nodemap argument as NULL.

Add the NULL to the try_to_migrate_pages() invocation.

This patch should be added to the Memory Hotplug series after patch
N1.1-pass-page_list-to-steal_page.patch (for 2.6.12-rc5-mhp1).

Signed-off-by: Ray Bryant <raybry@sgi.com>
--

 page_alloc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.12-rc5-mhp1-memory-hotplug/mm/page_alloc.c
===================================================================
--- linux-2.6.12-rc5-mhp1-memory-hotplug.orig/mm/page_alloc.c	2005-06-21 10:43:14.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-memory-hotplug/mm/page_alloc.c	2005-06-21 10:43:14.000000000 -0700
@@ -823,7 +823,7 @@ retry:
 	on_each_cpu(lru_drain_schedule, NULL, 1, 1);
 
 	rest = grab_capturing_pages(&page_list, start_pfn, nr_pages);
-	remains = try_to_migrate_pages(&page_list);
+	remains = try_to_migrate_pages(&page_list, NULL);
 	if (rest || !list_empty(&page_list)) {
 		if (remains == -ENOSPC) {
 			/* A swap device should be added. */

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
