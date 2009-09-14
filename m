Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B94326B0055
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 01:19:56 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so923209ana.26
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 22:20:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Sep 2009 17:20:02 +1200
Message-ID: <202cde0e0909132220v6a28ce5che6b216d296aeb33d@mail.gmail.com>
Subject: [PATCH 3/3] Export of hugetlb_file_setup function. (Take 3)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch provides drivers with export of hugetlb_file_setup function.
This patch exports hugetlb_file_setup function, that will be used to
create a file on the internal vfsmount. Also it adds enum entry just
to notify that  file is created by device driver. Accounting rules are
the same as for HUGETLB_ANONHUGE_INODE.

fs/hugetlbfs/inode.c    |    1 +
include/linux/hugetlb.h |    5 +++++
2 files changed, 6 insertions(+)
---
Signed-off-by: Alexey Korolev <akorolev@infradead.org>

diff -aurp clean/fs/hugetlbfs/inode.c patched/fs/hugetlbfs/inode.c
--- clean/fs/hugetlbfs/inode.c	2009-09-11 15:33:48.000000000 +1200
+++ patched/fs/hugetlbfs/inode.c	2009-09-11 15:29:31.000000000 +1200
@@ -1012,6 +1012,7 @@ out_shm_unlock:
 	}
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(hugetlb_file_setup);

 static int __init init_hugetlbfs_fs(void)
 {
diff -aurp clean/include/linux/hugetlb.h patched/include/linux/hugetlb.h
--- clean/include/linux/hugetlb.h	2009-09-11 15:33:48.000000000 +1200
+++ patched/include/linux/hugetlb.h	2009-09-11 20:09:02.000000000 +1200
@@ -123,6 +126,11 @@ enum {
 	 * accounting rules do not apply
 	 */
 	HUGETLB_ANONHUGE_INODE  = 2,
+	/*
+	 * The file is being created for use of device drivers,shmfs
+	 * accounting rules do not apply
+	 */
+	HUGETLB_DEVBACK_INODE	= 3,
 };

 #ifdef CONFIG_HUGETLBFS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
