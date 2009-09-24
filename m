Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CDC766B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 07:28:57 -0400 (EDT)
Subject: [PATCH] mm: includecheck fix: vmalloc.c
From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Content-Type: text/plain
Date: Thu, 24 Sep 2009 16:58:47 +0530
Message-Id: <1253791727.5860.18.camel@ht.satnam>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, WANG Cong <xiyou.wangcong@gmail.com>, Mike Smith <scgtrp@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


fix the following 'make includecheck' warning:

  mm/vmalloc.c: linux/highmem.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Mike Smith <scgtrp@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/vmalloc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 69511e6..2f7c9d7 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -25,7 +25,6 @@
 #include <linux/rcupdate.h>
 #include <linux/pfn.h>
 #include <linux/kmemleak.h>
-#include <linux/highmem.h>
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
-- 
1.6.0.6


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
