Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id A2C816B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 20:55:51 -0400 (EDT)
Received: by lamp12 with SMTP id p12so17486440lam.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 17:55:51 -0700 (PDT)
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com. [209.85.217.179])
        by mx.google.com with ESMTPS id a1si8601614lbg.46.2015.09.09.17.55.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 17:55:50 -0700 (PDT)
Received: by lbcjc2 with SMTP id jc2so14909302lbc.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 17:55:49 -0700 (PDT)
From: Alexey Klimov <alexey.klimov@linaro.org>
Subject: [PATCH] mm/zswap: remove unneeded initialization to NULL in zswap_entry_find_get
Date: Thu, 10 Sep 2015 03:55:43 +0300
Message-Id: <1441846543-10448-1-git-send-email-alexey.klimov@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sjennings@variantweb.net
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, klimov.linux@gmail.com, yury.norov@gmail.com, Alexey Klimov <alexey.klimov@linaro.org>

On the next line entry variable will be re-initialized so no need
to init it with NULL.

Signed-off-by: Alexey Klimov <alexey.klimov@linaro.org>
---
 mm/zswap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 48a1d08..4f2f965 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -325,7 +325,7 @@ static void zswap_entry_put(struct zswap_tree *tree,
 static struct zswap_entry *zswap_entry_find_get(struct rb_root *root,
 				pgoff_t offset)
 {
-	struct zswap_entry *entry = NULL;
+	struct zswap_entry *entry;
 
 	entry = zswap_rb_search(root, offset);
 	if (entry)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
