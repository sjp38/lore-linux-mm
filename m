Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 818345F0001
	for <linux-mm@kvack.org>; Sun, 12 Apr 2009 23:55:39 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so849960wah.22
        for <linux-mm@kvack.org>; Sun, 12 Apr 2009 20:56:28 -0700 (PDT)
Date: Mon, 13 Apr 2009 12:56:23 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] hugetlbfs: return negative error code for bad mount option
Message-ID: <20090413035623.GA4156@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

This fixes the following BUG:

# mount -o size=MM -t hugetlbfs none /huge
hugetlbfs: Bad value 'MM' for mount option 'size=MM'
------------[ cut here ]------------
kernel BUG at fs/super.c:996!

Also, remove unused #include <linux/quotaops.h>

Cc: William Irwin <wli@holomorphy.com>
Cc: stable@kernel.org
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 23a3c76..153d968 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -26,7 +26,6 @@
 #include <linux/pagevec.h>
 #include <linux/parser.h>
 #include <linux/mman.h>
-#include <linux/quotaops.h>
 #include <linux/slab.h>
 #include <linux/dnotify.h>
 #include <linux/statfs.h>
@@ -842,7 +841,7 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
 bad_val:
  	printk(KERN_ERR "hugetlbfs: Bad value '%s' for mount option '%s'\n",
 	       args[0].from, p);
- 	return 1;
+ 	return -EINVAL;
 }
 
 static int

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
