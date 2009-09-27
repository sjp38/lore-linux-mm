Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EE0AA6B005A
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 23:15:47 -0400 (EDT)
Received: by pxi2 with SMTP id 2so4512152pxi.11
        for <linux-mm@kvack.org>; Sat, 26 Sep 2009 20:15:52 -0700 (PDT)
From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 5/5] mm: remove duplicated #include
Date: Sun, 27 Sep 2009 11:15:46 +0800
Message-Id: <1254021346-944-1-git-send-email-weiyi.huang@gmail.com>
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, Huang Weiyi <weiyi.huang@gmail.com>
List-ID: <linux-mm.kvack.org>

Remove duplicated #include('s) in
  mm/vmalloc.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
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
1.6.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
