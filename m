Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 684F36B006C
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 09:26:29 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so187691382pdb.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:26:29 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id zu3si997229pbc.175.2015.03.23.06.26.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 06:26:28 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so191748083pac.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:26:28 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 1/2] zsmalloc: remove synchronize_rcu from zs_compact()
Date: Mon, 23 Mar 2015 22:26:38 +0900
Message-Id: <1427117199-2763-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1427117199-2763-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1427117199-2763-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Do not synchronize rcu in zs_compact(). Neither zsmalloc not
zram use rcu.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index cf4f074..d1bbb04 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1776,8 +1776,6 @@ unsigned long zs_compact(struct zs_pool *pool)
 		nr_migrated += __zs_compact(pool, class);
 	}
 
-	synchronize_rcu();
-
 	return nr_migrated;
 }
 EXPORT_SYMBOL_GPL(zs_compact);
-- 
2.3.3.262.ge80e85a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
