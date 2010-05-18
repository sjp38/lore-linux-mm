Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8428A6B01D0
	for <linux-mm@kvack.org>; Mon, 17 May 2010 22:42:19 -0400 (EDT)
Received: by pvg12 with SMTP id 12so1406388pvg.14
        for <linux-mm@kvack.org>; Mon, 17 May 2010 19:42:18 -0700 (PDT)
From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH]mm:highmem.h remove obsolete memclear_highpage_flush() call.
Date: Mon, 17 May 2010 19:42:05 -0700
Message-Id: <1274150525-2738-1-git-send-email-justinmattock@gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Justin P. Mattock" <justinmattock@gmail.com>
List-ID: <linux-mm.kvack.org>

memclear_highpage_flush has been changed over to
zero_user_page for some time now. I think it's
safe to say it's o.k. to remove all of it.
(but correct me if I'm wrong).

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>


---
 include/linux/highmem.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 74152c0..c77f913 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -173,12 +173,6 @@ static inline void zero_user(struct page *page,
 	zero_user_segments(page, start, start + size, 0, 0);
 }
 
-static inline void __deprecated memclear_highpage_flush(struct page *page,
-			unsigned int offset, unsigned int size)
-{
-	zero_user(page, offset, size);
-}
-
 #ifndef __HAVE_ARCH_COPY_USER_HIGHPAGE
 
 static inline void copy_user_highpage(struct page *to, struct page *from,
-- 
1.6.5.2.180.gc5b3e

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
