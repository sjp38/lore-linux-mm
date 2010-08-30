Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 93AAF6B01F3
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 18:31:41 -0400 (EDT)
Date: Mon, 30 Aug 2010 15:31:03 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V4 2/8] Cleancache: cleancache_poolid in superblock
Message-ID: <20100830223103.GA1247@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

[PATCH V4 2/8] Cleancache: cleancache_poolid in superblock

Add cleancache_poolid to superblock structure... not tied
to CONFIG_CLEANCACHE so as to avoid unnecessary clutter.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 fs.h                                     |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-2.6.36-rc3/include/linux/fs.h	2010-08-29 09:36:04.000000000 -0600
+++ linux-2.6.36-rc3-cleancache/include/linux/fs.h	2010-08-30 09:20:43.000000000 -0600
@@ -1381,6 +1381,11 @@ struct super_block {
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
