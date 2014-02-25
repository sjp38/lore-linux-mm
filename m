Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 73DC86B0103
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:19:26 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id y10so4635116pdj.1
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:19:26 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id wp1si20852776pab.223.2014.02.25.06.19.24
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 06:19:25 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v6 21/22] ext4: Fix typos
Date: Tue, 25 Feb 2014 09:18:37 -0500
Message-Id: <1393337918-28265-22-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

Comment fix only

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext4/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 9462730..14a9744 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3691,7 +3691,7 @@ void ext4_truncate(struct inode *inode)
 
 	/*
 	 * There is a possibility that we're either freeing the inode
-	 * or it completely new indode. In those cases we might not
+	 * or it's a completely new inode. In those cases we might not
 	 * have i_mutex locked because it's not necessary.
 	 */
 	if (!(inode->i_state & (I_NEW|I_FREEING)))
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
