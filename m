Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id D94456B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 18:15:38 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so2144iec.5
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 15:15:38 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id qo6si18593740igb.27.2014.06.17.15.15.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 15:15:38 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id a13so5587535igq.2
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 15:15:38 -0700 (PDT)
Date: Tue, 17 Jun 2014 15:15:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slab: mark enable_cpucache as init text
Message-ID: <alpine.DEB.2.02.1406171515030.32660@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

enable_cpucache() is only called for bootstrap, so it may be moved to init.text 
and freed after boot.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3861,7 +3861,7 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 }
 
 /* Called with slab_mutex held always */
-static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
+static int __init enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int err;
 	int limit = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
