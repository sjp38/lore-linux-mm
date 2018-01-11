Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 326D66B0260
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 22:41:06 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a74so363680pfg.20
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 19:41:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r59sor6589754plb.9.2018.01.10.19.41.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 19:41:04 -0800 (PST)
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: [PATCH v2] zsmalloc: use U suffix for negative literals being shifted
Date: Wed, 10 Jan 2018 19:41:18 -0800
Message-Id: <1515642078-4259-1-git-send-email-nick.desaulniers@gmail.com>
In-Reply-To: <20180110055338.h3cs5hw7mzsdtcad@eng-minchan1.roam.corp.google.com>
References: <20180110055338.h3cs5hw7mzsdtcad@eng-minchan1.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, Matthew Wilcox <willy@infradead.org>, Nick Desaulniers <nick.desaulniers@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fixes warnings about shifting unsigned literals being undefined
behavior.

Suggested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
---
Changes since v1:
* Use L suffix in addition to U, as suggested (link->next is unsigned long).

 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 683c065..b9040bd 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1057,7 +1057,7 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
 			 * Reset OBJ_TAG_BITS bit to last link to tell
 			 * whether it's allocated object or not.
 			 */
-			link->next = -1 << OBJ_TAG_BITS;
+			link->next = -1UL << OBJ_TAG_BITS;
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
