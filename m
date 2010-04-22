Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 95FBA6B01F3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 08:15:00 -0400 (EDT)
Subject: Cleancache [PATCH 1/7] (was Transcendent Memory): cleancache_poolid in superblock
Reply-To: dan.magenheimer@oracle.com
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Message-Id: <E1O4vI9-0006ZT-B4@ca-server1.us.oracle.com>
Date: Thu, 22 Apr 2010 05:14:01 -0700
Sender: owner-linux-mm@kvack.org
To: adilger@sun.com, akpm@linux-foundation.org, chris.mason@oracle.com, dave.mccracken@oracle.com, JBeulich@novell.com, jeremy@goop.org, joel.becker@oracle.com, kurt.hackel@oracle.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, matthew@wil.cx, mfasheh@suse.com, ngupta@vflare.org, npiggin@suse.de, ocfs2-devel@oss.oracle.com, riel@redhat.com, tytso@mit.edu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

Cleancache [PATCH 1/7] (was Transcendent Memory): cleancache_poolid in superblock

Add cleancache_poolid to superblock structure... not tied
to CONFIG_CLEANCACHE so as to avoid unnecessary clutter.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 fs.h                                     |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-2.6.34-rc5/include/linux/fs.h	2010-04-19 17:29:56.000000000 -0600
+++ linux-2.6.34-rc5-cleancache/include/linux/fs.h	2010-04-21 10:06:28.000000000 -0600
@@ -1383,6 +1383,11 @@ struct super_block {
 	 * generic_show_options()
 	 */
 	char *s_options;
+
+	/*
+	 * Saved pool identifier for cleancache (-1 means none)
+	 */
+	int cleancache_poolid;
 };
 
 extern struct timespec current_fs_time(struct super_block *sb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
