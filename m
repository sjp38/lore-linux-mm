Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4256B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 13:18:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so140675plo.9
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:18:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r78-v6sor826238pfa.49.2018.06.20.10.18.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 10:18:24 -0700 (PDT)
Date: Wed, 20 Jun 2018 22:50:46 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] include: dax: new-return-type-vm_fault_t
Message-ID: <20180620172046.GA27894@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, dan.j.williams@intel.com, jack@suse.cz, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, ross.zwisler@linux.intel.com, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Use new return type vm_fault_t for fault handler. For now,
this is just documenting that the function returns a VM_FAULT
value rather than an errno. Once all instances are converted,
vm_fault_t will become a distinct type.

commit 1c8f422059ae ("mm: change return type to vm_fault_t")

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/dax.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/dax.h b/include/linux/dax.h
index 7fddea8..11852d2 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -122,7 +122,7 @@ size_t dax_copy_from_iter(struct dax_device *dax_dev, pgoff_t pgoff, void *addr,
 
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		const struct iomap_ops *ops);
-int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
+vm_fault_t dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
 		    pfn_t *pfnp, int *errp, const struct iomap_ops *ops);
 vm_fault_t dax_finish_sync_fault(struct vm_fault *vmf,
 		enum page_entry_size pe_size, pfn_t pfn);
-- 
1.9.1
