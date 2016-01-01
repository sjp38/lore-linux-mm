Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 139DF6B000D
	for <linux-mm@kvack.org>; Thu, 31 Dec 2015 22:58:56 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id e65so110760854pfe.1
        for <linux-mm@kvack.org>; Thu, 31 Dec 2015 19:58:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 29si46800124pfq.140.2015.12.31.19.58.55
        for <linux-mm@kvack.org>;
        Thu, 31 Dec 2015 19:58:55 -0800 (PST)
Subject: [-mm PATCH] dax: fix dax_pmd_dbg build warning
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 31 Dec 2015 19:58:28 -0800
Message-ID: <20160101035828.29910.59955.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org

Fixes below warning from commit 3cb108f941deb
"dax-add-support-for-fsync-sync-v6" in -next.

    fs/dax.c: In function a??__dax_pmd_faulta??:
    fs/dax.c:916:15: warning: passing argument 1 of a??__dax_dbga?? from incompatible pointer type
         dax_pmd_dbg(bdev, address,
                   ^
    fs/dax.c:738:13: note: expected a??struct buffer_head *a?? but argument is of type a??struct block_device *a??
     static void __dax_dbg(struct buffer_head *bh, unsigned long address,

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 4ff61b412383..41cf4ee0b859 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -913,7 +913,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			error = dax_radix_entry(mapping, pgoff, dax.sector,
 					true, true);
 			if (error) {
-				dax_pmd_dbg(bdev, address,
+				dax_pmd_dbg(&bh, address,
 						"PMD radix insertion failed");
 				goto fallback;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
