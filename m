Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 768296B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 08:45:59 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so11392859pde.28
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 05:45:59 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id ph10si33565150pbb.289.2013.12.30.05.45.56
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 05:45:57 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 1/3] VFS: Add the declaration of shrink_pagecache_parent
Date: Mon, 30 Dec 2013 21:45:16 +0800
Message-Id: <110dae9d100e1a7221627fb9890c1c10d70ec3b1.1388409687.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>


Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 include/linux/dcache.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index bf72e9a..6262171 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -249,6 +249,7 @@ extern struct dentry *d_find_any_alias(struct inode *inode);
 extern struct dentry * d_obtain_alias(struct inode *);
 extern void shrink_dcache_sb(struct super_block *);
 extern void shrink_dcache_parent(struct dentry *);
+extern void shrink_pagecache_parent(struct dentry *);
 extern void shrink_dcache_for_umount(struct super_block *);
 extern int d_invalidate(struct dentry *);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
