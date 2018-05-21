Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 06DD56B0008
	for <linux-mm@kvack.org>; Mon, 21 May 2018 11:20:59 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t11-v6so4520988pgn.9
        for <linux-mm@kvack.org>; Mon, 21 May 2018 08:20:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k10-v6sor1000896pgn.183.2018.05.21.08.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 08:20:57 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v2 03/12] arch/x86/kernel/pci-calgary_64: update usage of address zone modifiers
Date: Mon, 21 May 2018 23:20:24 +0800
Message-Id: <1526916033-4877-4-git-send-email-yehs2007@gmail.com>
In-Reply-To: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Muli Ben-Yehuda <mulix@mulix.org>, Jon Mason <jdmason@kudzu.us>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

From: Huaisheng Ye <yehs1@lenovo.com>

Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.
__GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated by OR.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Muli Ben-Yehuda <mulix@mulix.org>
Cc: Jon Mason <jdmason@kudzu.us>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/kernel/pci-calgary_64.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/pci-calgary_64.c b/arch/x86/kernel/pci-calgary_64.c
index 35c461f..c89717d 100644
--- a/arch/x86/kernel/pci-calgary_64.c
+++ b/arch/x86/kernel/pci-calgary_64.c
@@ -445,7 +445,7 @@ static void* calgary_alloc_coherent(struct device *dev, size_t size,
 	npages = size >> PAGE_SHIFT;
 	order = get_order(size);
 
-	flag &= ~(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32);
+	flag &= ~__GFP_ZONE_MASK;
 
 	/* alloc enough pages (and possibly more) */
 	ret = (void *)__get_free_pages(flag, order);
-- 
1.8.3.1
