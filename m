Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 59CED6B0036
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 20:50:22 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 3 Jul 2013 10:44:00 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 597453578053
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:50:13 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r630ZEmp57802936
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:35:14 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r630oCgQ014659
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:50:12 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 4/5] mm/slub: Drop unnecessary nr_partials
Date: Wed,  3 Jul 2013 08:49:52 +0800
Message-Id: <1372812593-7617-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

This patch remove unused nr_partials variable.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slub.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4649ff0..84b84f4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5269,7 +5269,6 @@ __initcall(slab_sysfs_init);
 #ifdef CONFIG_SLABINFO
 void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 {
-	unsigned long nr_partials = 0;
 	unsigned long nr_slabs = 0;
 	unsigned long nr_objs = 0;
 	unsigned long nr_free = 0;
@@ -5281,7 +5280,6 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 		if (!n)
 			continue;
 
-		nr_partials += n->nr_partial;
 		nr_slabs += atomic_long_read(&n->nr_slabs);
 		nr_objs += atomic_long_read(&n->total_objects);
 		nr_free += count_partial(n, count_free);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
