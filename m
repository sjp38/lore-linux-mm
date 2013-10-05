Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 82A426B0036
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 13:32:50 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so5289239pbc.23
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 10:32:50 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so5353433pdj.4
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 10:32:47 -0700 (PDT)
Message-ID: <52504D38.1030402@gmail.com>
Date: Sun, 06 Oct 2013 01:32:40 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm/page_alloc.c: Get rid of unused marco LONG_ALIGN
References: <52504CF8.6000708@gmail.com>
In-Reply-To: <52504CF8.6000708@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

The macro is nowhere used, so remove it.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/page_alloc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1fb13b6..9d8508d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3881,8 +3881,6 @@ static inline unsigned long wait_table_bits(unsigned long size)
 	return ffz(~size);
 }
 
-#define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
-
 /*
  * Check if a pageblock contains reserved pages
  */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
