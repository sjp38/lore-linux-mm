Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 943DF6B0197
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 07:51:00 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id mc8so2101018pbc.21
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 04:51:00 -0800 (PST)
Received: from psmtp.com ([74.125.245.159])
        by mx.google.com with SMTP id pl8si6417581pbb.254.2013.11.08.04.50.58
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 04:50:59 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zwu.kernel@gmail.com>;
	Fri, 8 Nov 2013 05:50:57 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A56B06E803A
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 07:50:52 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA8Co2n79240910
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 12:50:54 GMT
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rA8Clhuo014304
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 05:47:43 -0700
From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 1/3] mm, slub: fix the typo in include/linux/slub_def.h
Date: Fri,  8 Nov 2013 20:47:36 +0800
Message-Id: <1383914858-14533-1-git-send-email-zwu.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 include/linux/slub_def.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index cc0b67e..f56bfa9 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -11,7 +11,7 @@
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
 	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
-	FREE_FASTPATH,		/* Free to cpu slub */
+	FREE_FASTPATH,		/* Free to cpu slab */
 	FREE_SLOWPATH,		/* Freeing not to cpu slab */
 	FREE_FROZEN,		/* Freeing to frozen slab */
 	FREE_ADD_PARTIAL,	/* Freeing moves slab to partial list */
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
