Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 7BB746B005D
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 07:07:25 -0400 (EDT)
Received: by ghrr1 with SMTP id r1so2172314ghr.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 04:07:24 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH] mm/slab: Fix typo _RET_IP -> _RET_IP_
Date: Tue, 25 Sep 2012 08:07:08 -0300
Message-Id: <1348571229-844-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-janitors@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>

The bug was introduced by commit 7c0cb9c64f83
"mm, slab: Replace 'caller' type, void* -> unsigned long".

Cc: Pekka Enberg <penberg@kernel.org>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slab.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d011030..ca3849f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3869,7 +3869,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 {
 	void *ret;
 
-	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP);
+	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
