Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3CE6B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 21:12:01 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so3696069wid.6
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 18:12:00 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id p15si10826634wiv.42.2014.12.09.18.11.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 18:12:00 -0800 (PST)
Message-ID: <5487AB3F.7050807@huawei.com>
Date: Wed, 10 Dec 2014 10:09:03 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V3 2/2] x86/mm: use min instead of min_t
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, dave@sr71.net, Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-tip-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>

The type of "MAX_DMA_PFN" and "xXx_pfn" are both unsigned long now, so use
min() instead of min_t().

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
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
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
