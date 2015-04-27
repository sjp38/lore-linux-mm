Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 31A156B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 03:00:34 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so119782781iec.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:00:34 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id o3si15375044icv.34.2015.04.27.00.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 00:00:33 -0700 (PDT)
Received: by igbhj9 with SMTP id hj9so54698693igb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:00:33 -0700 (PDT)
From: Derek Robson <robsonde@gmail.com>
Subject: [PATCH] mm: Missing a blank line after declarations
Date: Mon, 27 Apr 2015 19:00:30 +1200
Message-Id: <1430118030-7023-1-git-send-email-robsonde@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Derek Robson <robsonde@gmail.com>

This patch fixes warning found with checkpatch.pl error in cleancache.c
WARNING: Missing a blank line after declarations

This patch adds one blank line to meet the preferred style.

Signed-off-by: Derek Robson <robsonde@gmail.com>
---
 mm/cleancache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/cleancache.c b/mm/cleancache.c
index 8fc5081..3111a52 100644
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
2.3.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
