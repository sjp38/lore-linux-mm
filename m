Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 59EF59000C3
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 00:14:55 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 01/14] dcache: fix __d_alloc prototype to use const
Date: Fri,  8 Jul 2011 14:14:33 +1000
Message-Id: <1310098486-6453-2-git-send-email-david@fromorbit.com>
In-Reply-To: <1310098486-6453-1-git-send-email-david@fromorbit.com>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/internal.h |    2 +-
 fs/libfs.c    |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/internal.h b/fs/internal.h
index 996862d..ae47c48 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -139,4 +139,4 @@ extern int invalidate_inodes(struct super_block *, bool);
 /*
  * dcache.c
  */
-extern struct dentry *__d_alloc(struct super_block *, struct qstr *);
+extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
diff --git a/fs/libfs.c b/fs/libfs.c
index 8cdcd1c..a4a0bdf 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -16,6 +16,8 @@
 
 #include <asm/uaccess.h>
 
+#include "internal.h"
+
 static inline int simple_positive(struct dentry *dentry)
 {
 	return dentry->d_inode && !d_unhashed(dentry);
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
