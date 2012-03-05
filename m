Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 9EBFD6B0083
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:54:28 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 6/7] sysfs: Push file_update_time() into bin_page_mkwrite()
Date: Mon,  5 Mar 2012 15:54:17 +0100
Message-Id: <1330959258-23211-7-git-send-email-jack@suse.cz>
In-Reply-To: <1330959258-23211-1-git-send-email-jack@suse.cz>
References: <1330959258-23211-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/sysfs/bin.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
index a475983..614b2b5 100644
--- a/fs/sysfs/bin.c
+++ b/fs/sysfs/bin.c
@@ -228,6 +228,8 @@ static int bin_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	ret = 0;
 	if (bb->vm_ops->page_mkwrite)
 		ret = bb->vm_ops->page_mkwrite(vma, vmf);
+	else
+		file_update_time(file);
 
 	sysfs_put_active(attr_sd);
 	return ret;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
