Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6DDEB6B0085
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 08:30:19 -0400 (EDT)
Received: by gyg13 with SMTP id 13so615720gyg.14
        for <linux-mm@kvack.org>; Fri, 22 Oct 2010 05:29:39 -0700 (PDT)
From: Liu Aleaxander <aleaxander@gmail.com>
Subject: [PATCH] mm: fix the wrong comments for kunmap_high
Date: Fri, 22 Oct 2010 20:29:19 +0800
Message-Id: <1287750559-2942-1-git-send-email-Aleaxander@gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Liu Aleaxander <Aleaxander@gmail.com>
List-ID: <linux-mm.kvack.org>

Fix the wrong function descrption for kunmap_high function

Signed-off-by: Liu Aleaxander <Aleaxander@gmail.com>
---
 mm/highmem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 7a0aa1b..a0bc98f 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -242,7 +242,7 @@ void *kmap_high_get(struct page *page)
 #endif
 
 /**
- * kunmap_high - map a highmem page into memory
+ * kunmap_high - unmap a highmem page into memory
  * @page: &struct page to unmap
  *
  * If ARCH_NEEDS_KMAP_HIGH_GET is not defined then this may be called
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
