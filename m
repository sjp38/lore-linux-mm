Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A95516B01F3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 08:16:31 -0400 (EDT)
Subject: Cleancache [PATCH 4/7] (was Transcendent Memory): ext3 hook
Reply-To: dan.magenheimer@oracle.com
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Message-Id: <E1O4vJ7-0006bE-Lh@ca-server1.us.oracle.com>
Date: Thu, 22 Apr 2010 05:15:01 -0700
Sender: owner-linux-mm@kvack.org
To: adilger@sun.com, akpm@linux-foundation.org, chris.mason@oracle.com, dave.mccracken@oracle.com, JBeulich@novell.com, jeremy@goop.org, joel.becker@oracle.com, kurt.hackel@oracle.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, matthew@wil.cx, mfasheh@suse.com, ngupta@vflare.org, npiggin@suse.de, ocfs2-devel@oss.oracle.com, riel@redhat.com, tytso@mit.edu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Cleancache [PATCH 4/7] (was Transcendent Memory): ext3 hook

Filesystems must explicitly enable cleancache.  For ext3,
all other cleancache hooks are in the VFS layer.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 super.c                                  |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.34-rc5/fs/ext3/super.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/ext3/super.c	2010-04-21 10:06:48.000000000 -0600
@@ -37,6 +37,7 @@
 #include <linux/quotaops.h>
 #include <linux/seq_file.h>
 #include <linux/log2.h>
+#include <linux/cleancache.h>
 
 #include <asm/uaccess.h>
 
@@ -1344,6 +1345,7 @@ static int ext3_setup_super(struct super
 	} else {
 		ext3_msg(sb, KERN_INFO, "using internal journal");
 	}
+	sb->cleancache_poolid = cleancache_init_fs(PAGE_SIZE);
 	return res;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
