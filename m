Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58C636B02E9
	for <linux-mm@kvack.org>; Wed, 16 May 2018 01:44:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j14-v6so1888988pfn.11
        for <linux-mm@kvack.org>; Tue, 15 May 2018 22:44:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j5-v6si1484542pgs.281.2018.05.15.22.44.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 22:44:29 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/14] dax: make the dax_iomap_fault prototype consistent
Date: Wed, 16 May 2018 07:43:37 +0200
Message-Id: <20180516054348.15950-4-hch@lst.de>
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dax.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/dax.h b/include/linux/dax.h
index dc65ece825ee..a292bccdc274 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -183,7 +183,7 @@ void dax_flush(struct dax_device *dax_dev, void *addr, size_t size);
 
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		const struct iomap_ops *ops);
-int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
+vm_fault_t dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
 		    pfn_t *pfnp, int *errp, const struct iomap_ops *ops);
 vm_fault_t dax_finish_sync_fault(struct vm_fault *vmf,
 		enum page_entry_size pe_size, pfn_t pfn);
-- 
2.17.0
