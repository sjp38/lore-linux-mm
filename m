Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B6123831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 09:04:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q125so33653979pgq.8
        for <linux-mm@kvack.org>; Thu, 18 May 2017 06:04:35 -0700 (PDT)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id x19si5070690pgj.131.2017.05.18.06.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 06:04:34 -0700 (PDT)
Received: from svr-orw-fem-06.mgc.mentorg.com ([147.34.97.120])
	by relay1.mentorg.com with esmtp
	id 1dBL6X-0006Gb-Sq from Harish_Kandiga@mentor.com
	for linux-mm@kvack.org; Thu, 18 May 2017 06:04:34 -0700
From: Harish Jenny K N <harish_kandiga@mentor.com>
Subject: [PATCH] mm/swapfile.c: fix a minor coding style issue
Date: Thu, 18 May 2017 18:34:28 +0530
Message-ID: <1495112668-11826-1-git-send-email-harish_kandiga@mentor.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This commit fixes a minor coding style issue in swapfile.c
adding an underscore in procswaps_init call.

Signed-off-by: Harish Jenny K N <harish_kandiga@mentor.com>
---
 mm/swapfile.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4f6cba1..9a6004c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2426,12 +2426,12 @@ static int swaps_open(struct inode *inode, struct file *file)
 	.poll		= swaps_poll,
 };

-static int __init procswaps_init(void)
+static int __init proc_swaps_init(void)
 {
 	proc_create("swaps", 0, NULL, &proc_swaps_operations);
 	return 0;
 }
-__initcall(procswaps_init);
+__initcall(proc_swaps_init);
 #endif /* CONFIG_PROC_FS */

 #ifdef MAX_SWAPFILES_CHECK
--
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
