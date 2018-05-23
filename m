Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 011A76B026D
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:08:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x23-v6so13363117pfm.7
        for <linux-mm@kvack.org>; Wed, 23 May 2018 10:08:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3-v6sor5176840pgs.48.2018.05.23.10.08.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 10:08:16 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v3 8/9] include/linux/highmem.h: update usage of movableflags
Date: Thu, 24 May 2018 01:08:06 +0800
Message-Id: <1527095286-5165-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, hch@lst.de, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Christoph Hellwig <hch@infradead.org>

From: Huaisheng Ye <yehs1@lenovo.com>

GFP_HIGHUSER_MOVABLE doesn't equal to GFP_HIGHUSER | __GFP_MOVABLE,
modify it to adapt patch of getting rid of GFP_ZONE_TABLE/BAD.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 include/linux/highmem.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 0690679..5383c9e 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -159,8 +159,8 @@ static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
 			struct vm_area_struct *vma,
 			unsigned long vaddr)
 {
-	struct page *page = alloc_page_vma(GFP_HIGHUSER | movableflags,
-			vma, vaddr);
+	struct page *page = alloc_page_vma(movableflags ?
+		GFP_HIGHUSER_MOVABLE : GFP_HIGHUSER, vma, vaddr);
 
 	if (page)
 		clear_user_highpage(page, vaddr);
-- 
1.8.3.1
