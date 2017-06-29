Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2D926B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 07:35:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u62so85665239pgb.13
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 04:35:00 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id b6si3259622pll.83.2017.06.29.04.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 04:34:59 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id z6so12805414pfk.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 04:34:59 -0700 (PDT)
From: Pushkar Jambhlekar <pushkar.iit@gmail.com>
Subject: [PATCH] mm: adding newline after declaration
Date: Thu, 29 Jun 2017 17:04:52 +0530
Message-Id: <1498736092-3216-1-git-send-email-pushkar.iit@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pushkar Jambhlekar <pushkar.iit@gmail.com>

Adding newline after declaration to follow coding guideline

Signed-off-by: Pushkar Jambhlekar <pushkar.iit@gmail.com>
---
 mm/cleancache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/cleancache.c b/mm/cleancache.c
index f7b9fdc..051c5d0 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -305,6 +305,7 @@ static int __init init_cleancache(void)
 {
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *root = debugfs_create_dir("cleancache", NULL);
+
 	if (root == NULL)
 		return -ENXIO;
 	debugfs_create_u64("succ_gets", S_IRUGO, root, &cleancache_succ_gets);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
