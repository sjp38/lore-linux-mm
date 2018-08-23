Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16F3E6B2A32
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:08:14 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z24-v6so2537770plo.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:08:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7-v6sor1194276pgi.126.2018.08.23.06.08.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 06:08:13 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/3] mm/sparse: expand the CONFIG_SPARSEMEM_EXTREME range in __nr_to_section()
Date: Thu, 23 Aug 2018 21:07:31 +0800
Message-Id: <20180823130732.9489-3-richard.weiyang@gmail.com>
In-Reply-To: <20180823130732.9489-1-richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com, Wei Yang <richard.weiyang@gmail.com>

When CONFIG_SPARSEMEM_EXTREME is not defined, mem_section is a static
two dimension array. This means !mem_section[SECTION_NR_TO_ROOT(nr)] is
always true.

This patch expand the CONFIG_SPARSEMEM_EXTREME range to return a proper
mem_section when CONFIG_SPARSEMEM_EXTREME is not defined.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mmzone.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2dc52a..33086f86d1a7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1155,9 +1155,9 @@ static inline struct mem_section *__nr_to_section(unsigned long nr)
 #ifdef CONFIG_SPARSEMEM_EXTREME
 	if (!mem_section)
 		return NULL;
-#endif
 	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
 		return NULL;
+#endif
 	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
 }
 extern int __section_nr(struct mem_section* ms);
-- 
2.15.1
