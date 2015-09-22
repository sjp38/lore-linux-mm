Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A70DE6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:40:17 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so571117pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:40:17 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id fb9si125619pab.76.2015.09.21.23.40.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Sep 2015 23:40:16 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH] zsmalloc: add comments for ->inuse to zspage
Date: Tue, 22 Sep 2015 14:39:39 +0800
Message-ID: <1442903979-11814-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..1f66d5b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -38,6 +38,7 @@
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
  *	page->mapping: class index and fullness group of the zspage
+ *	page->inuse: the pages number that is used in this zspage
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
