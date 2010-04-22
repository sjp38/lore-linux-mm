Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D776C6B01FA
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:28:49 -0400 (EDT)
Date: Thu, 22 Apr 2010 06:27:49 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Cleancache [PATCH 1/7] (was Transcendent Memory):
	cleancache_poolid in superblock
Message-ID: <20100422132749.GA27287@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

(Sorry for resend... Mail server DNS problems sending to some recipients)

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
