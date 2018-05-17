Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 80FD06B038D
	for <linux-mm@kvack.org>; Thu, 17 May 2018 02:11:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 74-v6so1673413wme.0
        for <linux-mm@kvack.org>; Wed, 16 May 2018 23:11:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b26-v6si184849eda.336.2018.05.16.23.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 23:11:16 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4H5iTAv047820
	for <linux-mm@kvack.org>; Thu, 17 May 2018 02:11:14 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2j0yqyh8v0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 May 2018 02:11:14 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 17 May 2018 07:11:12 +0100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] hexagon: Drop the unused variable zero_page_mask
Date: Thu, 17 May 2018 11:41:05 +0530
Message-Id: <20180517061105.30447-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rkuo@codeaurora.org, linux@roeck-us.net, vdavydov.dev@gmail.com, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hexagon arch does not seem to have subscribed to _HAVE_COLOR_ZERO_PAGE
framework. Hence zero_page_mask variable is not needed.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
I will have to request some one with hexagon system to compile and
test this patch. Dont have access to hardware.

 arch/hexagon/include/asm/pgtable.h | 1 -
 arch/hexagon/mm/init.c             | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/arch/hexagon/include/asm/pgtable.h b/arch/hexagon/include/asm/pgtable.h
index aef02f7ca8aa..65125d0b02dd 100644
--- a/arch/hexagon/include/asm/pgtable.h
+++ b/arch/hexagon/include/asm/pgtable.h
@@ -30,7 +30,6 @@
 
 /* A handy thing to have if one has the RAM. Declared in head.S */
 extern unsigned long empty_zero_page;
-extern unsigned long zero_page_mask;
 
 /*
  * The PTE model described here is that of the Hexagon Virtual Machine,
diff --git a/arch/hexagon/mm/init.c b/arch/hexagon/mm/init.c
index 192584d5ac2f..1495d45e472d 100644
--- a/arch/hexagon/mm/init.c
+++ b/arch/hexagon/mm/init.c
@@ -39,9 +39,6 @@ unsigned long __phys_offset;	/*  physical kernel offset >> 12  */
 /*  Set as variable to limit PMD copies  */
 int max_kernel_seg = 0x303;
 
-/*  think this should be (page_size-1) the way it's used...*/
-unsigned long zero_page_mask;
-
 /*  indicate pfn's of high memory  */
 unsigned long highstart_pfn, highend_pfn;
 
-- 
2.11.0
