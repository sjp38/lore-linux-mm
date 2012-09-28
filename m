Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id BE6DE6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 05:59:56 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] make GFP_NOTRACK flag unconditional
Date: Fri, 28 Sep 2012 13:56:34 +0400
Message-Id: <1348826194-21781-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Mel Gorman <mgorman@suse.de>

There was a general sentiment in a recent discussion (See
https://lkml.org/lkml/2012/9/18/258) that the __GFP flags should be
defined unconditionally. Currently, the only offender is GFP_NOTRACK,
which is conditional to KMEMCHECK.

This simple patch makes it unconditional.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/gfp.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f9bc873..02c1c97 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -30,11 +30,7 @@ struct vm_area_struct;
 #define ___GFP_HARDWALL		0x20000u
 #define ___GFP_THISNODE		0x40000u
 #define ___GFP_RECLAIMABLE	0x80000u
-#ifdef CONFIG_KMEMCHECK
 #define ___GFP_NOTRACK		0x200000u
-#else
-#define ___GFP_NOTRACK		0
-#endif
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
 
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
