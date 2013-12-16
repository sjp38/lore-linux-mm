Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A881D6B003B
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:01:01 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kl14so3033935pab.19
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:01:01 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id g5si9128828pav.114.2013.12.16.07.00.57
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 07:00:57 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 3/5] VFS: Add the declaration of shrink_pagecache_parent
Date: Mon, 16 Dec 2013 07:00:07 -0800
Message-Id: <1e2c2695163198cc660ef7a8761edcdae9e01612.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>


Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 include/linux/dcache.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 57e87e7..ce11098 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -247,6 +247,7 @@ extern struct dentry *d_find_any_alias(struct inode *inode);
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
