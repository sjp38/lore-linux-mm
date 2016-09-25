Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4924928024B
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 03:33:03 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 92so172068182iom.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 00:33:03 -0700 (PDT)
Received: from smtpbg303.qq.com (smtpbg303.qq.com. [184.105.206.26])
        by mx.google.com with ESMTPS id m184si5094577iom.29.2016.09.25.00.33.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Sep 2016 00:33:02 -0700 (PDT)
From: ysxie@foxmail.com
Subject: [PATCH] mm/page_isolation: fix typo: "paes" -> "pages"
Date: Sun, 25 Sep 2016 15:32:44 +0800
Message-Id: <1474788764-5774-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz
Cc: iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, wangxq10@lzu.edu.cn, neilzhang1123@hotmail.com, qiuxishi@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

trivial typo fix in comment

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 mm/page_isolation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 064b7fb..a5594bf 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -55,7 +55,7 @@ static int set_migratetype_isolate(struct page *page,
 		ret = 0;
 
 	/*
-	 * immobile means "not-on-lru" paes. If immobile is larger than
+	 * immobile means "not-on-lru" pages. If immobile is larger than
 	 * removable-by-driver pages reported by notifier, we'll fail.
 	 */
 
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
