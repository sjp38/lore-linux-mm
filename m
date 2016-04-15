Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D553F6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 14:35:46 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so142672343pac.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:35:46 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id t5si3810470pac.211.2016.04.15.11.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 11:35:45 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id 184so59482865pff.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:35:45 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm: thp: correct split_huge_pages file permission
Date: Fri, 15 Apr 2016 11:10:05 -0700
Message-Id: <1460743805-2560-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, hughd@google.com, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

split_huge_pages doesn't support get method at all, so the read permission
sounds confusing, change the permission to write only.

And, add "\n" to the output of set method to make it more readable.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 mm/huge_memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86f9f8b..8adf3c2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3454,7 +3454,7 @@ next:
 		}
 	}
 
-	pr_info("%lu of %lu THP split", split, total);
+	pr_info("%lu of %lu THP split\n", split, total);
 
 	return 0;
 }
@@ -3465,7 +3465,7 @@ static int __init split_huge_pages_debugfs(void)
 {
 	void *ret;
 
-	ret = debugfs_create_file("split_huge_pages", 0644, NULL, NULL,
+	ret = debugfs_create_file("split_huge_pages", 0200, NULL, NULL,
 			&split_huge_pages_fops);
 	if (!ret)
 		pr_warn("Failed to create split_huge_pages in debugfs");
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
