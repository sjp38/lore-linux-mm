Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0904F6B039F
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 03:10:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r129so2660322pgr.18
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 00:10:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f19si15635928pgk.27.2017.04.05.00.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 00:10:30 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, swap: Remove unused function prototype
Date: Wed,  5 Apr 2017 15:10:17 +0800
Message-Id: <20170405071017.23677-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

This is a code cleanup patch, no functionality changes.  There are 2
unused function prototype in swap.h, they are removed.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/swap.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 486494e6b2fc..ba5882419a7d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -411,9 +411,6 @@ struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
 
-extern int get_swap_slots(int n, swp_entry_t *slots);
-extern void swapcache_free_batch(swp_entry_t *entries, int n);
-
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
