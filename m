Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1246E6B025E
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:38:01 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id c25so167224887qtg.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:38:01 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id m124si13205989qke.228.2017.02.01.15.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:38:00 -0800 (PST)
From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 2/4] mm: Fix checkpatch warnings, whitespace
Date: Thu,  2 Feb 2017 10:37:18 +1100
Message-Id: <1485992240-10986-3-git-send-email-me@tobin.cc>
In-Reply-To: <1485992240-10986-1-git-send-email-me@tobin.cc>
References: <1485992240-10986-1-git-send-email-me@tobin.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Tobin C Harding <me@tobin.cc>

From: Tobin C Harding <me@tobin.cc>

Patch fixes whitespace checkpatch warnings.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 mm/memory.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index cc5fa12..3562314 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -30,7 +30,7 @@
 
 /*
  * 05.04.94  -  Multi-page memory management added for v1.1.
- * 		Idea by Alex Bligh (alex@cconcepts.co.uk)
+ *              Idea by Alex Bligh (alex@cconcepts.co.uk)
  *
  * 16.07.99  -  Support of BIGMEM added by Gerhard Wichert, Siemens AG
  *		(Gerhard.Wichert@pdb.siemens.de)
@@ -82,9 +82,9 @@
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
-struct page *mem_map;
-
 EXPORT_SYMBOL(max_mapnr);
+
+struct page *mem_map;
 EXPORT_SYMBOL(mem_map);
 #endif
 
@@ -96,7 +96,6 @@ EXPORT_SYMBOL(mem_map);
  * and ZONE_HIGHMEM.
  */
 void * high_memory;
-
 EXPORT_SYMBOL(high_memory);
 
 /*
@@ -120,10 +119,10 @@ static int __init disable_randmaps(char *s)
 __setup("norandmaps", disable_randmaps);
 
 unsigned long zero_pfn __read_mostly;
-unsigned long highest_memmap_pfn __read_mostly;
-
 EXPORT_SYMBOL(zero_pfn);
 
+unsigned long highest_memmap_pfn __read_mostly;
+
 /*
  * CONFIG_MMU architectures set up ZERO_PAGE in their paging_init()
  */
@@ -3696,8 +3695,8 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
                  * VM_FAULT_OOM), there is no need to kill anything.
                  * Just clean up the OOM state peacefully.
                  */
-                if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
-                        mem_cgroup_oom_synchronize(false);
+		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
+			mem_cgroup_oom_synchronize(false);
 	}
 
 	/*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
