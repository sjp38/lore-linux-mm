Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9D128089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 01:21:11 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so222809726pfb.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 22:21:11 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id r74si9198349pfg.146.2017.02.08.22.20.45
        for <linux-mm@kvack.org>;
        Wed, 08 Feb 2017 22:21:10 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v2] mm/zsmalloc: fix comment in zsmalloc
Date: Thu, 9 Feb 2017 14:13:42 +0800
Message-ID: <1486620822-36826-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, guohanjun@huawei.com

The class index and fullness group are not encoded in (first)page->mapping
any more, after commit 3783689a1aa8 ("zsmalloc: introduce zspage
structure"). Instead, they are store in struct zspage. Just delete this
unneeded comment.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Hanjun Guo <guohanjun@huawei.com>
---
v2:
 * just delete the comment for it is no need anymore, suggested by Sergey.

 mm/zsmalloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9cc3c0b..08c1a84 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -268,10 +268,6 @@ struct zs_pool {
 #endif
 };
 
-/*
- * A zspage's class index and fullness group
- * are encoded in its (first)page->mapping
- */
 #define FULLNESS_BITS	2
 #define CLASS_BITS	8
 #define ISOLATED_BITS	3
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
