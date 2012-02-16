Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 2C88F6B00EC
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:46:54 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/11] fuse: Push file_update_time() into fuse_page_mkwrite()
Date: Thu, 16 Feb 2012 14:46:15 +0100
Message-Id: <1329399979-3647-8-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-1-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net

CC: Miklos Szeredi <miklos@szeredi.hu>
CC: fuse-devel@lists.sourceforge.net
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fuse/file.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 4a199fd..eade72e 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1323,6 +1323,7 @@ static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 */
 	struct inode *inode = vma->vm_file->f_mapping->host;
 
+	file_update_time(vma->vm_file);
 	fuse_wait_on_page_writeback(inode, page->index);
 	return 0;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
