Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22D038E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 15:38:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i68-v6so4217685pfb.9
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 12:38:32 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id i13-v6si2534924pgo.128.2018.09.27.12.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 12:38:30 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm: dax: add comment for PFN_SPECIAL
Date: Fri, 28 Sep 2018 03:38:09 +0800
Message-Id: <1538077089-14550-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The comment for PFN_SPECIAL is missed in pfn_t.h. Add comment to get
consistent with other pfn flags.

Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/pfn_t.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 21713dc..d2e5dd4 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -9,6 +9,7 @@
  * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
  * PFN_DEV - pfn is not covered by system memmap by default
  * PFN_MAP - pfn has a dynamic page mapping established by a device driver
+ * PFN_SPECIAL - indicates that _PAGE_SPECIAL should be used for DAX ptes
  */
 #define PFN_FLAGS_MASK (((u64) ~PAGE_MASK) << (BITS_PER_LONG_LONG - PAGE_SHIFT))
 #define PFN_SG_CHAIN (1ULL << (BITS_PER_LONG_LONG - 1))
-- 
1.8.3.1
