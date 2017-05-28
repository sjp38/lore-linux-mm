Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC9C56B0279
	for <linux-mm@kvack.org>; Sun, 28 May 2017 10:59:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id z62so11445009lfd.9
        for <linux-mm@kvack.org>; Sun, 28 May 2017 07:59:55 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id r74si4770480lfi.183.2017.05.28.07.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 May 2017 07:59:53 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id h4so4271466lfj.3
        for <linux-mm@kvack.org>; Sun, 28 May 2017 07:59:53 -0700 (PDT)
From: Yevgen Pronenko <y.pronenko@gmail.com>
Subject: [PATCH 1/1] mm: Convert to DEFINE_DEBUGFS_ATTRIBUTE
Date: Sun, 28 May 2017 16:59:48 +0200
Message-Id: <20170528145948.32127-1-y.pronenko@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: Yevgen Pronenko <y.pronenko@gmail.com>

The preffered strategy to define debugfs attributes is to use
DEFINE_DEBUGFS_ATTRIBUTE() macro and debugfs_create_file_unsafe()
function.

Signed-off-by: Yevgen Pronenko <y.pronenko@gmail.com>
---
 mm/memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 206902395512..b1b97b490791 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3300,14 +3300,14 @@ static int fault_around_bytes_set(void *data, u64 val)
 		fault_around_bytes = PAGE_SIZE; /* rounddown_pow_of_two(0) is undefined */
 	return 0;
 }
-DEFINE_SIMPLE_ATTRIBUTE(fault_around_bytes_fops,
+DEFINE_DEBUGFS_ATTRIBUTE(fault_around_bytes_fops,
 		fault_around_bytes_get, fault_around_bytes_set, "%llu\n");
 
 static int __init fault_around_debugfs(void)
 {
 	void *ret;
 
-	ret = debugfs_create_file("fault_around_bytes", 0644, NULL, NULL,
+	ret = debugfs_create_file_unsafe("fault_around_bytes", 0644, NULL, NULL,
 			&fault_around_bytes_fops);
 	if (!ret)
 		pr_warn("Failed to create fault_around_bytes in debugfs");
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
