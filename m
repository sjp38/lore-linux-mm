Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 473556B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 07:00:06 -0500 (EST)
Date: Thu, 14 Jan 2010 19:59:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] memory-hotplug: add 0x prefix to HEX block_size_bytes
Message-ID: <20100114115956.GA2512@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/base/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-mm.orig/drivers/base/memory.c	2010-01-14 19:55:40.000000000 +0800
+++ linux-mm/drivers/base/memory.c	2010-01-14 19:55:47.000000000 +0800
@@ -311,7 +311,7 @@ static SYSDEV_ATTR(removable, 0444, show
 static ssize_t
 print_block_size(struct class *class, char *buf)
 {
-	return sprintf(buf, "%lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
+	return sprintf(buf, "%#lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
 }
 
 static CLASS_ATTR(block_size_bytes, 0444, print_block_size, NULL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
