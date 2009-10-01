Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 170F3600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:27:51 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 17/31] Fix initialization of ipv4_route_lock
Date: Thu,  1 Oct 2009 19:38:00 +0530
Message-Id: <1254406080-16264-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Jeff Mahoney <jeffm@suse.com>, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Jeff Mahoney <jeffm@suse.com>

 It's CONFIG_PROC_FS, not CONFIG_PROCFS.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm/net/ipv4/route.c
===================================================================
--- mmotm.orig/net/ipv4/route.c
+++ mmotm/net/ipv4/route.c
@@ -3483,7 +3483,7 @@ int __init ip_rt_init(void)
 	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
 
-#ifdef CONFIG_PROCFS
+#ifdef CONFIG_PROC_FS
 	mutex_init(&ipv4_route_lock);
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
