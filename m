Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C4DE56B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 10:13:12 -0400 (EDT)
Received: by qwd6 with SMTP id 6so1787982qwd.14
        for <linux-mm@kvack.org>; Thu, 25 Aug 2011 07:12:52 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -mmotm] lib/string.c: fix kernel-doc for memchr_inv
Date: Thu, 25 Aug 2011 23:14:40 +0900
Message-Id: <1314281680-21553-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Christoph Lameter <cl@linux.com>

This fixes kernel-doc for memchr_inv() which is introduced by
lib-stringc-introduce-memchr_inv.patch in mmotm 2011-08-24-14-08

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Christoph Lameter <cl@linux.com>
---
 lib/string.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/string.c b/lib/string.c
index 18f5111..11df543 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -769,10 +769,10 @@ static void *check_bytes8(const u8 *start, u8 value, unsigned int bytes)
 }
 
 /**
- * memchr_inv - Find a character in an area of memory.
- * @s: The memory area
- * @c: The byte to search for
- * @n: The size of the area.
+ * memchr_inv - Find an unmatching character in an area of memory.
+ * @start: The memory area
+ * @c: Find a character other than c
+ * @bytes: The size of the area.
  *
  * returns the address of the first character other than @c, or %NULL
  * if the whole buffer contains just @c.
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
