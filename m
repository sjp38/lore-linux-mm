Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2DAwo6O029682
	for <linux-mm@kvack.org>; Sun, 13 Mar 2005 02:58:51 -0800 (PST)
From: pmeda@akamai.com
Date: Sun, 13 Mar 2005 03:07:31 -0800
Message-Id: <200503131107.DAA07271@allur.sanmateo.akamai.com>
Subject: [PATCH] sysfs: mount error path cleanup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sysfs mount error path sanity work. Perhaps we can panic here, but
did not want to disturb the code here.

Signed-off-by: Prasanna Meda <pmeda@akamai.com>

--- Linux/fs/sysfs/mount.c	Sun Mar 13 10:44:08 2005
+++ linux/fs/sysfs/mount.c	Sun Mar 13 10:45:25 2005
@@ -93,6 +93,7 @@
 			printk(KERN_ERR "sysfs: could not mount!\n");
 			err = PTR_ERR(sysfs_mount);
 			sysfs_mount = NULL;
+			unregister_filesystem(&sysfs_fs_type);
 			goto out_err;
 		}
 	} else
@@ -101,5 +102,6 @@
 	return err;
 out_err:
 	kmem_cache_destroy(sysfs_dir_cachep);
+	sysfs_dir_cachep = NULL;
 	goto out;
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
