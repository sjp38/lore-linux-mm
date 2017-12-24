Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5306B0033
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 21:33:53 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id d3so165863uae.19
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 18:33:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5sor2272283uad.193.2017.12.23.18.33.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Dec 2017 18:33:52 -0800 (PST)
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: [PATCH] zsmalloc: use U suffix for negative literals being shifted
Date: Sat, 23 Dec 2017 21:33:40 -0500
Message-Id: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Nick Desaulniers <nick.desaulniers@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fixes warnings about shifting unsigned literals being undefined
behavior.

Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 685049a..5d31458 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1056,7 +1056,7 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
 			 * Reset OBJ_TAG_BITS bit to last link to tell
 			 * whether it's allocated object or not.
 			 */
-			link->next = -1 << OBJ_TAG_BITS;
+			link->next = -1U << OBJ_TAG_BITS;
 		}
 		kunmap_atomic(vaddr);
 		page = next_page;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
