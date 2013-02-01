Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E3AE56B002E
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 05:44:30 -0500 (EST)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 18/18] ext4: Allow punch hole with bigalloc enabled
Date: Fri,  1 Feb 2013 11:43:44 +0100
Message-Id: <1359715424-32318-19-git-send-email-lczerner@redhat.com>
In-Reply-To: <1359715424-32318-1-git-send-email-lczerner@redhat.com>
References: <1359715424-32318-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, xfs@oss.sgi.com, Lukas Czerner <lczerner@redhat.com>

In commits 5f95d21fb6f2aaa52830e5b7fb405f6c71d3ab85 and
30bc2ec9598a1b156ad75217f2e7d4560efdeeab we've reworked punch_hole
implementation and there is noting holding us back from using punch hole
on file system with bigalloc feature enabled.

This has been tested with fsx and xfstests.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/inode.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index e7bf594..01cf049 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3530,11 +3530,6 @@ int ext4_punch_hole(struct file *file, loff_t offset, loff_t length)
 		return -EOPNOTSUPP;
 	}
 
-	if (EXT4_SB(inode->i_sb)->s_cluster_ratio > 1) {
-		/* TODO: Add support for bigalloc file systems */
-		return -EOPNOTSUPP;
-	}
-
 	return ext4_ext_punch_hole(file, offset, length);
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
