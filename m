Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2830C8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 18:16:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o18-v6so2447176pgv.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 15:16:45 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id h1-v6si3027014pgs.493.2018.09.27.15.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 15:16:43 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v2 PATCH] mm: dax: add comment for PFN_SPECIAL
Date: Fri, 28 Sep 2018 06:15:49 +0800
Message-Id: <1538086549-100536-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The comment for PFN_SPECIAL is missed in pfn_t.h. Add comment to get
consistent with other pfn flags.

Suggested-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v2: rephrase the comment per Dan

 include/linux/pfn_t.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 21713dc..d6cc4b5 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -9,6 +9,8 @@
  * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
  * PFN_DEV - pfn is not covered by system memmap by default
  * PFN_MAP - pfn has a dynamic page mapping established by a device driver
+ * PFN_SPECIAL - for CONFIG_FS_DAX_LIMITED builds to allow XIP, but not
+ *		 get_user_pages 
  */
 #define PFN_FLAGS_MASK (((u64) ~PAGE_MASK) << (BITS_PER_LONG_LONG - PAGE_SHIFT))
 #define PFN_SG_CHAIN (1ULL << (BITS_PER_LONG_LONG - 1))
-- 
1.8.3.1
