Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA6FD6B0263
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:17:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so189070212pfb.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 14:17:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fv2si13599089pad.86.2016.04.28.14.17.27
        for <linux-mm@kvack.org>;
        Thu, 28 Apr 2016 14:17:27 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v4 7/7] dax: fix a comment in dax_zero_page_range and dax_truncate_page
Date: Thu, 28 Apr 2016 15:16:58 -0600
Message-Id: <1461878218-3844-8-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Vishal Verma <vishal.l.verma@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew@wil.cx>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The distinction between PAGE_SIZE and PAGE_CACHE_SIZE was removed in

09cbfea mm, fs: get rid of PAGE_CACHE_* and page_cache_{get,release}
macros

The comments for the above functions described a distinction between
those, that is now redundant, so remove those paragraphs

Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---
 fs/dax.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index d8c974e..b8fa85a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1221,12 +1221,6 @@ static bool dax_range_is_aligned(struct block_device *bdev,
  * page in a DAX file.  This is intended for hole-punch operations.  If
  * you are truncating a file, the helper function dax_truncate_page() may be
  * more convenient.
- *
- * We work in terms of PAGE_SIZE here for commonality with
- * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
- * took care of disposing of the unnecessary blocks.  Even if the filesystem
- * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
- * since the file might be mmapped.
  */
 int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 							get_block_t get_block)
@@ -1279,12 +1273,6 @@ EXPORT_SYMBOL_GPL(dax_zero_page_range);
  *
  * Similar to block_truncate_page(), this function can be called by a
  * filesystem when it is truncating a DAX file to handle the partial page.
- *
- * We work in terms of PAGE_SIZE here for commonality with
- * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
- * took care of disposing of the unnecessary blocks.  Even if the filesystem
- * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
- * since the file might be mmapped.
  */
 int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 {
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
