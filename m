Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9826B02E7
	for <linux-mm@kvack.org>; Wed, 16 May 2018 01:44:19 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f11-v6so1952275plj.23
        for <linux-mm@kvack.org>; Tue, 15 May 2018 22:44:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b7-v6si12362pgn.583.2018.05.15.22.44.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 22:44:18 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/14] fs: make the filemap_page_mkwrite prototype consistent
Date: Wed, 16 May 2018 07:43:36 +0200
Message-Id: <20180516054348.15950-3-hch@lst.de>
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

!CONFIG_MMU version didn't agree with the rest of the kernel..

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f28e6f4..cf21ced98eff 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2748,7 +2748,7 @@ int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
 	return generic_file_mmap(file, vma);
 }
 #else
-int filemap_page_mkwrite(struct vm_fault *vmf)
+vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf)
 {
 	return -ENOSYS;
 }
-- 
2.17.0
