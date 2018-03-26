Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C63A56B0011
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 04:20:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b9so8460063pgu.13
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 01:20:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f11sor4532146pfn.123.2018.03.26.01.20.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 01:20:05 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/2] mm/sparse: pass the __highest_present_section_nr + 1 to alloc_func()
Date: Mon, 26 Mar 2018 16:19:55 +0800
Message-Id: <20180326081956.75275-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

In 'commit c4e1be9ec113 ("mm, sparsemem: break out of loops early")',
__highest_present_section_nr is introduced to reduce the loop counts for
present section. This is also helpful for usemap and memmap allocation.

This patch uses __highest_present_section_nr + 1 to optimize the loop.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 7af5e7a92528..505050346249 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -561,7 +561,7 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
 		map_count = 1;
 	}
 	/* ok, last chunk */
-	alloc_func(data, pnum_begin, NR_MEM_SECTIONS,
+	alloc_func(data, pnum_begin, __highest_present_section_nr+1,
 						map_count, nodeid_begin);
 }
 
-- 
2.15.1
