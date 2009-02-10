Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 538C86B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 08:18:04 -0500 (EST)
Received: by bwz28 with SMTP id 28so2563024bwz.14
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:18:02 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] Export symbol ksize()
Date: Tue, 10 Feb 2009 15:21:44 +0200
Message-Id: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

It needed for crypto.ko

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/slab.c |    1 +
 mm/slob.c |    1 +
 mm/slub.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index ddc41f3..4d00855 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4457,3 +4457,4 @@ size_t ksize(const void *objp)
 
 	return obj_size(virt_to_cache(objp));
 }
+EXPORT_SYMBOL(ksize);
diff --git a/mm/slob.c b/mm/slob.c
index bf7e8fc..52bc8a2 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -521,6 +521,7 @@ size_t ksize(const void *block)
 	} else
 		return sp->page.private;
 }
+EXPORT_SYMBOL(ksize);
 
 struct kmem_cache {
 	unsigned int size, align;
diff --git a/mm/slub.c b/mm/slub.c
index bdc9abb..0280eee 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2736,6 +2736,7 @@ size_t ksize(const void *object)
 	 */
 	return s->size;
 }
+EXPORT_SYMBOL(ksize);
 
 void kfree(const void *x)
 {
-- 
1.6.1.3.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
