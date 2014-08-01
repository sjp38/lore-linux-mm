Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 86A4F6B0055
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 09:27:56 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so5807984pad.7
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 06:27:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id c9si4902164pdn.254.2014.08.01.06.27.52
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 06:27:53 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v9 15/22] ext2: Remove xip.c and xip.h
Date: Fri,  1 Aug 2014 09:27:31 -0400
Message-Id: <746fb244d92097eb6d4159ff9bba2a69ea53a6e3.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

These files are now empty, so delete them

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext2/Makefile |  1 -
 fs/ext2/inode.c  |  1 -
 fs/ext2/namei.c  |  1 -
 fs/ext2/super.c  |  1 -
 fs/ext2/xip.c    | 15 ---------------
 fs/ext2/xip.h    | 16 ----------------
 6 files changed, 35 deletions(-)
 delete mode 100644 fs/ext2/xip.c
 delete mode 100644 fs/ext2/xip.h

diff --git a/fs/ext2/Makefile b/fs/ext2/Makefile
index f42af45..445b0e9 100644
--- a/fs/ext2/Makefile
+++ b/fs/ext2/Makefile
@@ -10,4 +10,3 @@ ext2-y := balloc.o dir.o file.o ialloc.o inode.o \
 ext2-$(CONFIG_EXT2_FS_XATTR)	 += xattr.o xattr_user.o xattr_trusted.o
 ext2-$(CONFIG_EXT2_FS_POSIX_ACL) += acl.o
 ext2-$(CONFIG_EXT2_FS_SECURITY)	 += xattr_security.o
-ext2-$(CONFIG_EXT2_FS_XIP)	 += xip.o
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index cba3833..154cbcf 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -34,7 +34,6 @@
 #include <linux/aio.h>
 #include "ext2.h"
 #include "acl.h"
-#include "xip.h"
 #include "xattr.h"
 
 static int __ext2_write_inode(struct inode *inode, int do_sync);
diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
index 846c356..7ca803f 100644
--- a/fs/ext2/namei.c
+++ b/fs/ext2/namei.c
@@ -35,7 +35,6 @@
 #include "ext2.h"
 #include "xattr.h"
 #include "acl.h"
-#include "xip.h"
 
 static inline int ext2_add_nondir(struct dentry *dentry, struct inode *inode)
 {
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 3ac6555..747e293 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -35,7 +35,6 @@
 #include "ext2.h"
 #include "xattr.h"
 #include "acl.h"
-#include "xip.h"
 
 static void ext2_sync_super(struct super_block *sb,
 			    struct ext2_super_block *es, int wait);
diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
deleted file mode 100644
index 66ca113..0000000
--- a/fs/ext2/xip.c
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- *  linux/fs/ext2/xip.c
- *
- * Copyright (C) 2005 IBM Corporation
- * Author: Carsten Otte (cotte@de.ibm.com)
- */
-
-#include <linux/mm.h>
-#include <linux/fs.h>
-#include <linux/genhd.h>
-#include <linux/buffer_head.h>
-#include <linux/blkdev.h>
-#include "ext2.h"
-#include "xip.h"
-
diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
deleted file mode 100644
index 87eeb04..0000000
--- a/fs/ext2/xip.h
+++ /dev/null
@@ -1,16 +0,0 @@
-/*
- *  linux/fs/ext2/xip.h
- *
- * Copyright (C) 2005 IBM Corporation
- * Author: Carsten Otte (cotte@de.ibm.com)
- */
-
-#ifdef CONFIG_EXT2_FS_XIP
-static inline int ext2_use_xip (struct super_block *sb)
-{
-	struct ext2_sb_info *sbi = EXT2_SB(sb);
-	return (sbi->s_mount_opt & EXT2_MOUNT_XIP);
-}
-#else
-#define ext2_use_xip(sb)			0
-#endif
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
