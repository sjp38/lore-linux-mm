Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id D665C6B0078
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:10:14 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 9so10556910ykp.8
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:10:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o1si9830601yhp.172.2015.01.12.15.10.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:10:14 -0800 (PST)
Date: Mon, 12 Jan 2015 15:10:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 18/20] dax: Add dax_zero_page_range
Message-Id: <20150112151012.b576357217d5f91cd3ddf63b@linux-foundation.org>
In-Reply-To: <1414185652-28663-19-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-19-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, 24 Oct 2014 17:20:50 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> [ported to 3.13-rc2]
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

I never know what this means :(

I switched it to 

[ross.zwisler@linux.intel.com: ported to 3.13-rc2]
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

but perhaps that was wrong?



also, coupla typos:


diff -puN fs/dax.c~dax-add-dax_zero_page_range-fix fs/dax.c
--- a/fs/dax.c~dax-add-dax_zero_page_range-fix
+++ a/fs/dax.c
@@ -475,7 +475,7 @@ EXPORT_SYMBOL_GPL(dax_fault);
  * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
  * took care of disposing of the unnecessary blocks.  Even if the filesystem
  * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
- * since the file might be mmaped.
+ * since the file might be mmapped.
  */
 int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 							get_block_t get_block)
@@ -514,13 +514,13 @@ EXPORT_SYMBOL_GPL(dax_zero_page_range);
  * @get_block: The filesystem method used to translate file offsets to blocks
  *
  * Similar to block_truncate_page(), this function can be called by a
- * filesystem when it is truncating an DAX file to handle the partial page.
+ * filesystem when it is truncating a DAX file to handle the partial page.
  *
  * We work in terms of PAGE_CACHE_SIZE here for commonality with
  * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
  * took care of disposing of the unnecessary blocks.  Even if the filesystem
  * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
- * since the file might be mmaped.
+ * since the file might be mmapped.
  */
 int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 {
diff -puN include/linux/fs.h~dax-add-dax_zero_page_range-fix include/linux/fs.h
_


akpm3:/usr/src/linux-3.19-rc4> grep -r mmaped .| wc -l
70
akpm3:/usr/src/linux-3.19-rc4> grep -r mmapped .| wc -l 
107

lol.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
