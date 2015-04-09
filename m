Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 849396B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 16:44:13 -0400 (EDT)
Received: by widjs5 with SMTP id js5so2721427wid.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 13:44:13 -0700 (PDT)
Received: from mailrelay112.isp.belgacom.be (mailrelay112.isp.belgacom.be. [195.238.20.139])
        by mx.google.com with ESMTP id fx9si352517wib.15.2015.04.09.13.44.11
        for <linux-mm@kvack.org>;
        Thu, 09 Apr 2015 13:44:12 -0700 (PDT)
From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] slob: statify slob_alloc_node() and remove symbol
Date: Thu,  9 Apr 2015 22:44:07 +0200
Message-Id: <1428612247-319-1-git-send-email-fabf@skynet.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

slob_alloc_node() is only used in slob.c
This patch removes EXPORT_SYMBOL and statify function

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 mm/slob.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 6d55710..495df8e 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -532,7 +532,7 @@ int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
 	return 0;
 }
 
-void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
+static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
@@ -558,7 +558,6 @@ void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
 	return b;
 }
-EXPORT_SYMBOL(slob_alloc_node);
 
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
