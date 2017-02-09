Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBB728089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 22:27:25 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id x4so1443784wme.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 19:27:25 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id p8si4562099wma.83.2017.02.08.19.27.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 19:27:24 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] mm/zsmalloc: fix comment in zsmalloc
Date: Thu, 9 Feb 2017 11:23:39 +0800
Message-ID: <1486610619-57588-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, guohanjun@huawei.com

The class index and fullness group are not encoded in
(first)page->mapping any more, after commit 3783689a1aa8 ("zsmalloc:
introduce zspage structure"). Instead, they are store in struct zspage.

Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Hanjun Guo <guohanjun@huawei.com>
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9cc3c0b..4b87225 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -270,7 +270,7 @@ struct zs_pool {
 
 /*
  * A zspage's class index and fullness group
- * are encoded in its (first)page->mapping
+ * are stored in struct zspage.
  */
 #define FULLNESS_BITS	2
 #define CLASS_BITS	8
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
