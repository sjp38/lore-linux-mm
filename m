Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6366B0037
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 08:55:27 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so2334725pde.17
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 05:55:27 -0700 (PDT)
Received: from psmtp.com ([74.125.245.134])
        by mx.google.com with SMTP id ud7si2171047pac.62.2013.10.31.05.55.26
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 05:55:26 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zwu.kernel@gmail.com>;
	Thu, 31 Oct 2013 06:55:25 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C2EFDC40006
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 06:55:08 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9VCt21r234488
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 06:55:03 -0600
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9VCt1BA008481
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 06:55:01 -0600
From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 1/2] mm: fix the incorrect function name in alloc_low_pages()
Date: Thu, 31 Oct 2013 20:52:32 +0800
Message-Id: <1383223953-28803-1-git-send-email-zwu.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 arch/x86/mm/init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 04664cd..64d860f 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -53,12 +53,12 @@ __ref void *alloc_low_pages(unsigned int num)
 	if ((pgt_buf_end + num) > pgt_buf_top || !can_use_brk_pgt) {
 		unsigned long ret;
 		if (min_pfn_mapped >= max_pfn_mapped)
-			panic("alloc_low_page: ran out of memory");
+			panic("alloc_low_pages: ran out of memory");
 		ret = memblock_find_in_range(min_pfn_mapped << PAGE_SHIFT,
 					max_pfn_mapped << PAGE_SHIFT,
 					PAGE_SIZE * num , PAGE_SIZE);
 		if (!ret)
-			panic("alloc_low_page: can not alloc memory");
+			panic("alloc_low_pages: can not alloc memory");
 		memblock_reserve(ret, PAGE_SIZE * num);
 		pfn = ret >> PAGE_SHIFT;
 	} else {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
