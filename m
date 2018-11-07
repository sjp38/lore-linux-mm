Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29CF86B0515
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 10:08:52 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id n22-v6so15541236pff.2
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 07:08:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a23-v6si859679pls.322.2018.11.07.07.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 07:08:50 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA7F05dM141252
	for <linux-mm@kvack.org>; Wed, 7 Nov 2018 10:08:50 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nm0uwmjuu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Nov 2018 10:08:49 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 7 Nov 2018 15:08:43 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] mm/gup: fix follow_page_mask kernel-doc comment
Date: Wed,  7 Nov 2018 17:08:36 +0200
Message-Id: <1541603316-27832-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-doc@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Commit df06b37ffe5a ("mm/gup: cache dev_pagemap while pinning pages")
modified the signature of follow_page_mask() function but left the
parameter description behind.

Update the description to make the code and comments agree again.

While on it, update formatting of the return value description to match
Documentation/doc-guide/kernel-doc.rst guidelines.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/gup.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index f76e77a..aa43620 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -385,11 +385,17 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
  * @vma: vm_area_struct mapping @address
  * @address: virtual address to look up
  * @flags: flags modifying lookup behaviour
- * @page_mask: on output, *page_mask is set according to the size of the page
+ * @ctx: contains dev_pagemap for %ZONE_DEVICE memory pinning and a
+ *       pointer to output page_mask
  *
  * @flags can have FOLL_ flags set, defined in <linux/mm.h>
  *
- * Returns the mapped (struct page *), %NULL if no mapping exists, or
+ * When getting pages from ZONE_DEVICE memory, the @ctx->pgmap caches
+ * the device's dev_pagemap metadata to avoid repeating expensive lookups.
+ *
+ * On output, the @ctx->page_mask is set according to the size of the page.
+ *
+ * Return: the mapped (struct page *), %NULL if no mapping exists, or
  * an error pointer if there is a mapping to something not represented
  * by a page descriptor (see also vm_normal_page()).
  */
-- 
2.7.4
