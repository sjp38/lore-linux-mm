Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9EADE6B0083
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:52 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:51 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 08/12] rmap: make anon_vma_[chain_]free() static
Date: Thu, 30 Sep 2010 12:50:17 +0900
Message-Id: <1285818621-29890-9-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Make anon_vma_free() and anon_vma_chain_free() static. They are
called only in rmap.c and corresponding alloc functions are
already static.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 include/linux/rmap.h |    1 -
 mm/rmap.c            |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 490206c..be92e78 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -148,7 +148,6 @@ void unlink_anon_vmas(struct vm_area_struct *);
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
-void anon_vma_free(struct anon_vma *);
 
 static inline void anon_vma_merge(struct vm_area_struct *vma,
 				  struct vm_area_struct *next)
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c900dd..af7dc02 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -70,7 +70,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
 	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 }
 
-void anon_vma_free(struct anon_vma *anon_vma)
+static void anon_vma_free(struct anon_vma *anon_vma)
 {
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
@@ -80,7 +80,7 @@ static inline struct anon_vma_chain *anon_vma_chain_alloc(void)
 	return kmem_cache_alloc(anon_vma_chain_cachep, GFP_KERNEL);
 }
 
-void anon_vma_chain_free(struct anon_vma_chain *anon_vma_chain)
+static void anon_vma_chain_free(struct anon_vma_chain *anon_vma_chain)
 {
 	kmem_cache_free(anon_vma_chain_cachep, anon_vma_chain);
 }
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
