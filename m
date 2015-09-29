Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id AED236B025A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 11:47:14 -0400 (EDT)
Received: by qgez77 with SMTP id z77so9734272qge.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 08:47:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 143si21692896qhy.11.2015.09.29.08.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 08:47:13 -0700 (PDT)
Subject: [MM PATCH V4 3/6] slub: mark the dangling ifdef #else of
 CONFIG_SLUB_DEBUG
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 29 Sep 2015 17:47:33 +0200
Message-ID: <20150929154723.14465.6260.stgit@canyon>
In-Reply-To: <20150929154605.14465.98995.stgit@canyon>
References: <20150929154605.14465.98995.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The #ifdef of CONFIG_SLUB_DEBUG is located very far from
the associated #else.  For readability mark it with a comment.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 024eed32da2c..1cf98d89546d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1202,7 +1202,7 @@ unsigned long kmem_cache_flags(unsigned long object_size,
 
 	return flags;
 }
-#else
+#else /* !CONFIG_SLUB_DEBUG */
 static inline void setup_object_debug(struct kmem_cache *s,
 			struct page *page, void *object) {}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
