Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 914406B0255
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 14:19:57 -0400 (EDT)
Received: by lbcbn3 with SMTP id bn3so16612328lbc.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:19:56 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id xn6si3094915lbb.48.2015.08.27.11.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 11:19:56 -0700 (PDT)
Received: by labia3 with SMTP id ia3so18052479lab.3
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:19:55 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock.c: fix comment in the __next_mem_range()
Date: Fri, 28 Aug 2015 00:19:10 +0600
Message-Id: <1440699550-3348-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Baoquan He <bhe@redhat.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..0d24b01 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -972,7 +972,7 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
  * in type_b.
  *
  * @idx: pointer to u64 loop variable
- * @nid: nid: node selector, %NUMA_NO_NODE for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @flags: pick from blocks based on memory attributes
  * @type_a: pointer to memblock_type from where the range is taken
  * @type_b: pointer to memblock_type which excludes memory from being taken
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
