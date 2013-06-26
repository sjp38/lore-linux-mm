Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 118EF6B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 19:57:55 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 27 Jun 2013 09:55:05 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 4DFB13578051
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 09:57:49 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5QNvdax8585672
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 09:57:40 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5QNvlRt007073
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 09:57:48 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm/slub: Use node_nr_slabs and node_nr_objs in get_slabinfo
Date: Thu, 27 Jun 2013 07:57:39 +0800
Message-Id: <1372291059-9880-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1372291059-9880-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1372291059-9880-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use existing interface node_nr_slabs and node_nr_objs to get
nr_slabs and nr_objs.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slub.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e303b04..52098c2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5287,8 +5287,8 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
 		if (!n)
 			continue;
 
-		nr_slabs += atomic_long_read(&n->nr_slabs);
-		nr_objs += atomic_long_read(&n->total_objects);
+		nr_slabs += node_nr_slabs(n);
+		nr_objs += node_nr_objs(n);
 		nr_free += count_partial(n, &nr_inactive, count_free);
 		nr_inactive_slabs += nr_inactive;
 	}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
