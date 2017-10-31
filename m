Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCC7F6B0268
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 14:41:08 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h6so19773245oia.17
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:41:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l82si1282586oib.365.2017.10.31.11.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 11:41:08 -0700 (PDT)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH 3/6] hugetlb: expose hugetlbfs_inode_info in header
Date: Tue, 31 Oct 2017 19:40:49 +0100
Message-Id: <20171031184052.25253-4-marcandre.lureau@redhat.com>
In-Reply-To: <20171031184052.25253-1-marcandre.lureau@redhat.com>
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

The following patch is going to access hugetlbfs_inode_info field from
mm/shmem.c.

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
---
 fs/hugetlbfs/inode.c    | 10 ----------
 include/linux/hugetlb.h | 10 ++++++++++
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 59073e9f01a4..ea7b10357ac4 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -55,16 +55,6 @@ struct hugetlbfs_config {
 	umode_t			mode;
 };
 
-struct hugetlbfs_inode_info {
-	struct shared_policy policy;
-	struct inode vfs_inode;
-};
-
-static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
-{
-	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
-}
-
 int sysctl_hugetlb_shm_group;
 
 enum {
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8bbbd37ab105..f78daf54897d 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -278,6 +278,16 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 	return sb->s_fs_info;
 }
 
+struct hugetlbfs_inode_info {
+	struct shared_policy policy;
+	struct inode vfs_inode;
+};
+
+static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
+{
+	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
+}
+
 extern const struct file_operations hugetlbfs_file_operations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
-- 
2.15.0.rc0.40.gaefcc5f6f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
