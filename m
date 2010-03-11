Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC99B6B00D5
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 08:51:04 -0500 (EST)
Date: Thu, 11 Mar 2010 08:49:21 -0500 (EST)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] MEMORY MANAGEMENT: Remove deprecated
 memclear_highpage_flush().
Message-ID: <alpine.LFD.2.00.1003110847220.6408@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Since this routine is all of static, deprecated and unreferenced, it
seems safe to delete it.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---


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

========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

            Linux Consulting, Training and Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Twitter:                                       http://twitter.com/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
