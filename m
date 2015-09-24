Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DD76A6B025B
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 02:13:53 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so13675807pac.3
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 23:13:53 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id q3si16207378pap.6.2015.09.23.23.13.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Sep 2015 23:13:53 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH v2] zsmalloc: add comments for ->inuse to zspage
Date: Thu, 24 Sep 2015 14:13:14 +0800
Message-ID: <1443075194-26291-1-git-send-email-zhuhui@xiaomi.com>
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
index f135b1b..f62f2fb 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -38,6 +38,7 @@
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
  *	page->mapping: class index and fullness group of the zspage
+ *	page->inuse: the objects number that is used in this zspage
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
