Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CBBA06B02A4
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 06:06:09 -0400 (EDT)
Received: by pwi8 with SMTP id 8so1378941pwi.14
        for <linux-mm@kvack.org>; Sat, 10 Jul 2010 03:06:07 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] slob: remove unused funtion
Date: Sat, 10 Jul 2010 18:05:53 +0800
Message-Id: <1278756353-6884-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mpm@selenic.com, hannes@cmpxchg.org, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

funtion struct_slob_page_wrong_size() is not used anymore, remove it

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/slob.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index d582171..832d2b5 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -109,8 +109,6 @@ struct slob_page {
 		struct page page;
 	};
 };
-static inline void struct_slob_page_wrong_size(void)
-{ BUILD_BUG_ON(sizeof(struct slob_page) != sizeof(struct page)); }
 
 /*
  * free_slob_page: call before a slob_page is returned to the page allocator.
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
