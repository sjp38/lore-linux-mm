Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D26D6B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 18:45:56 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so58212951pgc.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 15:45:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n11si37788461plg.331.2016.11.30.15.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 15:45:55 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 2/6] dax: remove leading space from labels
Date: Wed, 30 Nov 2016 16:45:29 -0700
Message-Id: <1480549533-29038-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

No functional change.

As of this commit:

commit 218dd85887da (".gitattributes: set git diff driver for C source code
files")

git-diff and git-format-patch both generate diffs whose hunks are correctly
prefixed by function names instead of labels, even if those labels aren't
indented with spaces.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index be39633..b14335c 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -422,7 +422,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		return page;
 	}
 	entry = lock_slot(mapping, slot);
- out_unlock:
+out_unlock:
 	spin_unlock_irq(&mapping->tree_lock);
 	return entry;
 }
@@ -557,7 +557,7 @@ static int dax_load_hole(struct address_space *mapping, void **entry,
 				   vmf->gfp_mask | __GFP_ZERO);
 	if (!page)
 		return VM_FAULT_OOM;
- out:
+out:
 	vmf->page = page;
 	ret = finish_fault(vmf);
 	vmf->page = NULL;
@@ -659,7 +659,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	}
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
- unlock:
+unlock:
 	spin_unlock_irq(&mapping->tree_lock);
 	if (hole_fill) {
 		radix_tree_preload_end();
@@ -812,12 +812,12 @@ static int dax_writeback_one(struct block_device *bdev,
 	spin_lock_irq(&mapping->tree_lock);
 	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_DIRTY);
 	spin_unlock_irq(&mapping->tree_lock);
- unmap:
+unmap:
 	dax_unmap_atomic(bdev, &dax);
 	put_locked_mapping_entry(mapping, index, entry);
 	return ret;
 
- put_unlocked:
+put_unlocked:
 	put_unlocked_mapping_entry(mapping, index, entry2);
 	spin_unlock_irq(&mapping->tree_lock);
 	return ret;
@@ -1194,11 +1194,11 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		break;
 	}
 
- error_unlock_entry:
+error_unlock_entry:
 	vmf_ret = dax_fault_return(error) | major;
- unlock_entry:
+unlock_entry:
 	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
- finish_iomap:
+finish_iomap:
 	if (ops->iomap_end) {
 		int copied = PAGE_SIZE;
 
@@ -1255,7 +1255,7 @@ static int dax_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
 
 	return vmf_insert_pfn_pmd(vma, address, pmd, dax.pfn, write);
 
- unmap_fallback:
+unmap_fallback:
 	dax_unmap_atomic(bdev, &dax);
 	return VM_FAULT_FALLBACK;
 }
@@ -1379,9 +1379,9 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		break;
 	}
 
- unlock_entry:
+unlock_entry:
 	put_locked_mapping_entry(mapping, pgoff, entry);
- finish_iomap:
+finish_iomap:
 	if (ops->iomap_end) {
 		int copied = PMD_SIZE;
 
@@ -1396,7 +1396,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		ops->iomap_end(inode, pos, PMD_SIZE, copied, iomap_flags,
 				&iomap);
 	}
- fallback:
+fallback:
 	if (result == VM_FAULT_FALLBACK) {
 		split_huge_pmd(vma, pmd, address);
 		count_vm_event(THP_FAULT_FALLBACK);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
