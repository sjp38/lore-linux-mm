Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ECA286B0083
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:54 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:53 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 09/12] vmalloc: rename temporary variable in __insert_vmap_area()
Date: Thu, 30 Sep 2010 12:50:18 +0900
Message-Id: <1285818621-29890-10-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rename redundant 'tmp' to fix following sparse warnings:

 mm/vmalloc.c:296:34: warning: symbol 'tmp' shadows an earlier one
 mm/vmalloc.c:293:24: originally declared here

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/vmalloc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 6b8889d..7ce8ca5 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -293,13 +293,13 @@ static void __insert_vmap_area(struct vmap_area *va)
 	struct rb_node *tmp;
 
 	while (*p) {
-		struct vmap_area *tmp;
+		struct vmap_area *tmp_va;
 
 		parent = *p;
-		tmp = rb_entry(parent, struct vmap_area, rb_node);
-		if (va->va_start < tmp->va_end)
+		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
+		if (va->va_start < tmp_va->va_end)
 			p = &(*p)->rb_left;
-		else if (va->va_end > tmp->va_start)
+		else if (va->va_end > tmp_va->va_start)
 			p = &(*p)->rb_right;
 		else
 			BUG();
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
