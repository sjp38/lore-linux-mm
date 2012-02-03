Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id BA9046B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 03:21:04 -0500 (EST)
Received: by pbaa12 with SMTP id a12so3376712pba.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 00:21:04 -0800 (PST)
From: Geunsik Lim <geunsik.lim@gmail.com>
Subject: [PATCH] Fix potentially derefencing uninitialized 'r'.
Date: Fri,  3 Feb 2012 17:20:56 +0900
Message-Id: <1328257256-1296-1-git-send-email-geunsik.lim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@linux.intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

struct memblock_region 'r' will not be initialized potentially
because of while statement's condition in __next_mem_pfn_range()function.
Initialize struct memblock_region data structure by default.

Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 77b5f22..867f5a2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -671,7 +671,7 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 				unsigned long *out_end_pfn, int *out_nid)
 {
 	struct memblock_type *type = &memblock.memory;
-	struct memblock_region *r;
+	struct memblock_region *r = &type->regions[*idx];
 
 	while (++*idx < type->cnt) {
 		r = &type->regions[*idx];
-- 
1.7.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
