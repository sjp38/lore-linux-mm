Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5FF6B01FB
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 08:16:44 -0400 (EDT)
Subject: Cleancache [PATCH 7/7] (was Transcendent Memory): ocfs2 hook
Reply-To: dan.magenheimer@oracle.com
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Message-Id: <E1O4vK5-0000En-VO@ca-server1.us.oracle.com>
Date: Thu, 22 Apr 2010 05:16:01 -0700
Sender: owner-linux-mm@kvack.org
To: adilger@sun.com, akpm@linux-foundation.org, chris.mason@oracle.com, dave.mccracken@oracle.com, JBeulich@novell.com, jeremy@goop.org, joel.becker@oracle.com, kurt.hackel@oracle.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, matthew@wil.cx, mfasheh@suse.com, ngupta@vflare.org, npiggin@suse.de, ocfs2-devel@oss.oracle.com, riel@redhat.com, tytso@mit.edu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Cleancache [PATCH 7/7] (was Transcendent Memory): ocfs2 hook

Filesystems must explicitly enable cleancache.  Ocfs2 is
currently the only user of the clustered filesystem
interface but nevertheless, the cleancache hooks in the
VFS layer are sufficient for ocfs2.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Acked-by: Joel Becker <joel.becker@oracle.com>

Diffstat:
 super.c                                  |    3 +++
 1 file changed, 3 insertions(+)

--- linux-2.6.34-rc5/fs/ocfs2/super.c	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/fs/ocfs2/super.c	2010-04-21 10:13:13.000000000 -0600
@@ -42,6 +42,7 @@
 #include <linux/seq_file.h>
 #include <linux/quotaops.h>
 #include <linux/smp_lock.h>
+#include <linux/cleancache.h>
 
 #define MLOG_MASK_PREFIX ML_SUPER
 #include <cluster/masklog.h>
@@ -2233,6 +2234,8 @@ static int ocfs2_initialize_super(struct
 		mlog_errno(status);
 		goto bail;
 	}
+	sb->cleancache_poolid =
+		cleancache_init_shared_fs((char *)&uuid_net_key, PAGE_SIZE);
 
 bail:
 	mlog_exit(status);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
