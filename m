Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id E3C566B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 15:20:24 -0400 (EDT)
Received: by labns7 with SMTP id ns7so19150279lab.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 12:20:24 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id l5si3288305lbs.78.2015.08.27.12.20.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 12:20:23 -0700 (PDT)
Received: by laba3 with SMTP id a3so19074872lab.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 12:20:22 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH v1] mm/memblock: Add memblock_first_region_size() helper
Date: Fri, 28 Aug 2015 01:19:45 +0600
Message-Id: <1440703185-16072-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Baoquan He <bhe@redhat.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

Some architectures (like s390, microblaze and etc...) require size
of the first memory region. This patch provides new memblock_first_region_size()
helper for this case.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 include/linux/memblock.h | 1 +
 mm/memblock.c            | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index cc4b019..8a481e5 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -319,6 +319,7 @@ phys_addr_t memblock_phys_mem_size(void);
 phys_addr_t memblock_mem_size(unsigned long limit_pfn);
 phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
+phys_addr_t memblock_first_region_size(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 int memblock_is_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..fb4b7ca 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1463,6 +1463,11 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(void)
 	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
 }
 
+phys_addr_t __init_memblock memblock_first_region_size(void)
+{
+	return memblock.memory.regions[0].size;
+}
+
 void __init memblock_enforce_memory_limit(phys_addr_t limit)
 {
 	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
