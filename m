Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 6B8A96B0038
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 20:50:22 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 3 Jul 2013 10:44:02 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0B88E2CE804A
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:50:15 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r630ZGLm262486
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:35:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r630oERE014724
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 10:50:14 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 5/5] mm/slub: Use node_nr_slabs and node_nr_objs in get_slabinfo
Date: Wed,  3 Jul 2013 08:49:53 +0800
Message-Id: <1372812593-7617-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use existing interface node_nr_slabs and node_nr_objs to get
nr_slabs and nr_objs.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slub.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 84b84f4..d9135a8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5280,8 +5280,8 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 		if (!n)
 			continue;
 
-		nr_slabs += atomic_long_read(&n->nr_slabs);
-		nr_objs += atomic_long_read(&n->total_objects);
+		nr_slabs += node_nr_slabs(n);
+		nr_objs += node_nr_objs(n);
 		nr_free += count_partial(n, count_free);
 	}
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
