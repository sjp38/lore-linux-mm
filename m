Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 674C46B0194
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 07:47:55 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so2103544pde.15
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 04:47:55 -0800 (PST)
Received: from psmtp.com ([74.125.245.110])
        by mx.google.com with SMTP id ar5si6447167pbd.62.2013.11.08.04.47.51
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 04:47:52 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zwu.kernel@gmail.com>;
	Fri, 8 Nov 2013 07:47:50 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 35BDA6E803A
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 07:47:46 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA8ClmSC62259214
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 12:47:48 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rA8CllBK029344
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 07:47:47 -0500
From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 2/3] mm, slub: fix the typo in mm/slub.c
Date: Fri,  8 Nov 2013 20:47:37 +0800
Message-Id: <1383914858-14533-2-git-send-email-zwu.kernel@gmail.com>
In-Reply-To: <1383914858-14533-1-git-send-email-zwu.kernel@gmail.com>
References: <1383914858-14533-1-git-send-email-zwu.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 mm/slub.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index c3eb3d3..7a64327 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -155,7 +155,7 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 /*
  * Maximum number of desirable partial slabs.
  * The existence of more partial slabs makes kmem_cache_shrink
- * sort the partial list by the number of objects in the.
+ * sort the partial list by the number of objects in use.
  */
 #define MAX_PARTIAL 10
 
@@ -2829,8 +2829,8 @@ static struct kmem_cache *kmem_cache_node;
  * slab on the node for this slabcache. There are no concurrent accesses
  * possible.
  *
- * Note that this function only works on the kmalloc_node_cache
- * when allocating for the kmalloc_node_cache. This is used for bootstrapping
+ * Note that this function only works on the kmem_cache_node
+ * when allocating for the kmem_cache_node. This is used for bootstrapping
  * memory on a fresh node that has no slab structures yet.
  */
 static void early_kmem_cache_node_alloc(int node)
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
