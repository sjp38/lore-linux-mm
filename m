Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 0EAAD6B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:11:54 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so7573454pbc.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 03:11:53 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] shmem.c: Compilation failure in shmem_file_setup for !CONFIG_MMU
Date: Mon, 20 Feb 2012 06:11:32 -0500
Message-Id: <1329736292-19087-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

I disabled the CONFIG_MMU and tried to compile the kernel and got the
following problem:
In function a??shmem_file_setupa??:
error: implicit declaration of function a??ramfs_nommu_expand_for_mappinga??

This is because, we do not include ramfs.h for CONFIG_SHMEM.

Included linux/ramfs.h for both CONFIG_SHMEM as well as !CONFIG_SHMEM.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/shmem.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 269d049..4884188 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -30,6 +30,7 @@
 #include <linux/mm.h>
 #include <linux/export.h>
 #include <linux/swap.h>
+#include <linux/ramfs.h>
 
 static struct vfsmount *shm_mnt;
 
@@ -2442,8 +2443,6 @@ out4:
  * effectively equivalent, but much lighter weight.
  */
 
-#include <linux/ramfs.h>
-
 static struct file_system_type shmem_fs_type = {
 	.name		= "tmpfs",
 	.mount		= ramfs_mount,
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
