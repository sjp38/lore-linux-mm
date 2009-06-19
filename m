Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F02416B004D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 22:40:56 -0400 (EDT)
Message-ID: <4A3AFA41.4000708@oracle.com>
Date: Thu, 18 Jun 2009 19:38:57 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] page_alloc: fix kernel-doc warning
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Ummark function as having kernel-doc notation, fixing the
kernel-doc warning.

Warning(mm/page_alloc.c:4519): No description found for parameter 'zone'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.30-git14.orig/mm/page_alloc.c
+++ linux-2.6.30-git14/mm/page_alloc.c
@@ -4494,7 +4494,7 @@ void setup_per_zone_wmarks(void)
 	calculate_totalreserve_pages();
 }
 
-/**
+/*
  * The inactive anon list should be small enough that the VM never has to
  * do too much work, but large enough that each inactive page has a chance
  * to be referenced again before it is swapped out.


-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
