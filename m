Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDD36B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 08:16:37 -0400 (EDT)
Subject: Cleancache [PATCH 6/7] (was Transcendent Memory): ext4 hook
Reply-To: dan.magenheimer@oracle.com
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Message-Id: <E1O4vJl-0000Eb-Rr@ca-server1.us.oracle.com>
Date: Thu, 22 Apr 2010 05:15:41 -0700
Sender: owner-linux-mm@kvack.org
To: adilger@sun.com, akpm@linux-foundation.org, chris.mason@oracle.com, dave.mccracken@oracle.com, JBeulich@novell.com, jeremy@goop.org, joel.becker@oracle.com, kurt.hackel@oracle.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, matthew@wil.cx, mfasheh@suse.com, ngupta@vflare.org, npiggin@suse.de, ocfs2-devel@oss.oracle.com, riel@redhat.com, tytso@mit.edu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Cleancache [PATCH 6/7] (was Transcendent Memory): ext4 hook

Filesystems must explicitly enable cleancache.  For ext4,
all other cleancache hooks are in the VFS layer.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 super.c                                  |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.34-rc5/fs/ext4/super.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/ext4/super.c	2010-04-21 10:13:00.000000000 -0600
@@ -39,6 +39,7 @@
 #include <linux/ctype.h>
 #include <linux/log2.h>
 #include <linux/crc16.h>
+#include <linux/cleancache.h>
 #include <asm/uaccess.h>
 
 #include "ext4.h"
@@ -1784,6 +1785,7 @@ static int ext4_setup_super(struct super
 			EXT4_INODES_PER_GROUP(sb),
 			sbi->s_mount_opt);
 
+	sb->cleancache_poolid = cleancache_init_fs(PAGE_SIZE);
 	return res;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
