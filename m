Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EF9B96B00C1
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:26 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 35/60] c/r: add generic '->checkpoint' f_op to ext fses
Date: Wed, 22 Jul 2009 05:59:57 -0400
Message-Id: <1248256822-23416-36-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Dave Hansen <dave@linux.vnet.ibm.com>

This marks ext[234] as being checkpointable.  There will be many
more to do this to, but this is a start.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 fs/ext2/dir.c  |    1 +
 fs/ext2/file.c |    2 ++
 fs/ext3/dir.c  |    1 +
 fs/ext3/file.c |    1 +
 fs/ext4/dir.c  |    1 +
 fs/ext4/file.c |    1 +
 6 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 6cde970..78e9157 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -722,4 +722,5 @@ const struct file_operations ext2_dir_operations = {
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
 	.fsync		= simple_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 2b9e47d..edbc3dc 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -58,6 +58,7 @@ const struct file_operations ext2_file_operations = {
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 #ifdef CONFIG_EXT2_FS_XIP
@@ -73,6 +74,7 @@ const struct file_operations ext2_xip_file_operations = {
 	.open		= generic_file_open,
 	.release	= ext2_release_file,
 	.fsync		= simple_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 #endif
 
diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
index 3d724a9..54b05d2 100644
--- a/fs/ext3/dir.c
+++ b/fs/ext3/dir.c
@@ -48,6 +48,7 @@ const struct file_operations ext3_dir_operations = {
 #endif
 	.fsync		= ext3_sync_file,	/* BKL held */
 	.release	= ext3_release_dir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 
diff --git a/fs/ext3/file.c b/fs/ext3/file.c
index 5b49704..a421e07 100644
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -126,6 +126,7 @@ const struct file_operations ext3_file_operations = {
 	.fsync		= ext3_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ext3_file_inode_operations = {
diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index 9dc9316..f69404c 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -48,6 +48,7 @@ const struct file_operations ext4_dir_operations = {
 #endif
 	.fsync		= ext4_sync_file,
 	.release	= ext4_release_dir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 3f1873f..a99bcc3 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -195,6 +195,7 @@ const struct file_operations ext4_file_operations = {
 	.fsync		= ext4_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ext4_file_inode_operations = {
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
