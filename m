Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DBBD26B00EC
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:46:55 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/11] sysfs: Push file_update_time() into bin_page_mkwrite()
Date: Thu, 16 Feb 2012 14:46:17 +0100
Message-Id: <1329399979-3647-10-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-1-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/sysfs/bin.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
index a475983..6ceb16f 100644
--- a/fs/sysfs/bin.c
+++ b/fs/sysfs/bin.c
@@ -225,6 +225,8 @@ static int bin_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!sysfs_get_active(attr_sd))
 		return VM_FAULT_SIGBUS;
 
+	file_update_time(file);
+
 	ret = 0;
 	if (bb->vm_ops->page_mkwrite)
 		ret = bb->vm_ops->page_mkwrite(vma, vmf);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
