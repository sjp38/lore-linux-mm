Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 83D306B0259
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:26:22 -0400 (EDT)
Received: by qkas79 with SMTP id s79so1821150qka.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 05:26:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j188si15185212qhc.56.2015.09.28.05.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 05:26:21 -0700 (PDT)
Subject: [PATCH 3/7] slub: mark the dangling ifdef #else of CONFIG_SLUB_DEBUG
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 28 Sep 2015 14:26:19 +0200
Message-ID: <20150928122619.15409.68763.stgit@canyon>
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The #ifdef of CONFIG_SLUB_DEBUG is located very far from
the associated #else.  For readability mark it with a comment.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
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
