Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 759CD6B0071
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 07:26:41 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so2920103pdi.7
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 04:26:41 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id of10si1487176pdb.133.2014.12.11.04.26.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 04:26:40 -0800 (PST)
Date: Thu, 11 Dec 2014 04:26:28 -0800
From: tip-bot for Xishi Qiu <tipbot@zytor.com>
Message-ID: <tip-29258cf49eb794f00989fc47da8700759a42778b@git.kernel.org>
Reply-To: mingo@kernel.org, riel@redhat.com, hpa@zytor.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org, dave@sr71.net,
        tglx@linutronix.de, linux-mm@kvack.org, qiuxishi@huawei.com
In-Reply-To: <5487AB3F.7050807@huawei.com>
References: <5487AB3F.7050807@huawei.com>
Subject: [tip:x86/urgent] x86/mm: Use min() instead of min_t()
  in the e820 printout code
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@kernel.org, riel@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave@sr71.net, tglx@linutronix.de, qiuxishi@huawei.com, linux-mm@kvack.org

Commit-ID:  29258cf49eb794f00989fc47da8700759a42778b
Gitweb:     http://git.kernel.org/tip/29258cf49eb794f00989fc47da8700759a42778b
Author:     Xishi Qiu <qiuxishi@huawei.com>
AuthorDate: Wed, 10 Dec 2014 10:09:03 +0800
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Thu, 11 Dec 2014 11:35:02 +0100

x86/mm: Use min() instead of min_t() in the e820 printout code

The type of "MAX_DMA_PFN" and "xXx_pfn" are both unsigned long
now, so use min() instead of min_t().

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>
Cc: <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Link: http://lkml.kernel.org/r/5487AB3F.7050807@huawei.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/e820.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 49f8864..dd2f07a 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1114,8 +1114,8 @@ void __init memblock_find_dma_reserve(void)
 	 * at first, and assume boot_mem will not take below MAX_DMA_PFN
 	 */
 	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, NULL) {
-		start_pfn = min_t(unsigned long, start_pfn, MAX_DMA_PFN);
-		end_pfn = min_t(unsigned long, end_pfn, MAX_DMA_PFN);
+		start_pfn = min(start_pfn, MAX_DMA_PFN);
+		end_pfn = min(end_pfn, MAX_DMA_PFN);
 		nr_pages += end_pfn - start_pfn;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
