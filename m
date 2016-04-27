Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9776B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:44:44 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id fn8so86114295igb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 01:44:44 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id n5si8373265igd.63.2016.04.27.01.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 01:44:44 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id k129so5308264iof.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 01:44:43 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm/memory_failure: unify the output-prefix for printk()
Date: Wed, 27 Apr 2016 16:44:32 +0800
Message-Id: <1461746672-1080-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch aims to replace 'MCE' that was introduced by
'commit c2200538d89d ("mm/memory-failure: fix race with
compound page split/merge")' with 'Memory failure'.[1]

[1] https://lkml.org/lkml/2016/4/18/894

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/memory-failure.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 839aa53..2fcca6b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -894,7 +894,8 @@ int get_hwpoison_page(struct page *page)
 		if (head == compound_head(page))
 			return 1;
 
-		pr_info("MCE: %#lx cannot catch tail\n", page_to_pfn(page));
+		pr_info("Memory failure: %#lx cannot catch tail\n",
+			page_to_pfn(page));
 		put_page(head);
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
