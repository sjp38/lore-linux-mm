Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 681D96B02EA
	for <linux-mm@kvack.org>; Wed, 16 May 2018 01:44:33 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d9-v6so1987863plj.4
        for <linux-mm@kvack.org>; Tue, 15 May 2018 22:44:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r28-v6si1440235pgn.55.2018.05.15.22.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 22:44:32 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/14] mm: remove the unused device_private_entry_fault export
Date: Wed, 16 May 2018 07:43:38 +0200
Message-Id: <20180516054348.15950-5-hch@lst.de>
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/memremap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index db4e1a373e5f..59ee3b604b39 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -65,7 +65,6 @@ int device_private_entry_fault(struct vm_area_struct *vma,
 	 */
 	return page->pgmap->page_fault(vma, addr, page, flags, pmdp);
 }
-EXPORT_SYMBOL(device_private_entry_fault);
 #endif /* CONFIG_DEVICE_PRIVATE */
 
 static void pgmap_radix_release(struct resource *res, unsigned long end_pgoff)
-- 
2.17.0
