Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53E746B02F3
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:08:12 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so45154652pge.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:08:12 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id t13si11139706pgr.291.2017.07.27.05.08.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:08:11 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id v190so20371249pgv.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:08:11 -0700 (PDT)
From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 4/5] mm: huge_memory: constify attribute_group structures.
Date: Thu, 27 Jul 2017 17:37:20 +0530
Message-Id: <1501157240-3876-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, ying.huang@intel.com, aaron.lu@intel.com, mgorman@techsingularity.net, willy@linux.intel.com, rientjes@google.com, toshi.kani@hpe.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work with
const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86975de..36d86c3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -327,7 +327,7 @@ static ssize_t debug_cow_store(struct kobject *kobj,
 	NULL,
 };
 
-static struct attribute_group hugepage_attr_group = {
+static const struct attribute_group hugepage_attr_group = {
 	.attrs = hugepage_attr,
 };
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
