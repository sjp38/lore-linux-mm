Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6033B6B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 06:41:55 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/9] fb_defio: Push file_update_time() into fb_deferred_io_mkwrite()
Date: Thu,  1 Mar 2012 12:41:35 +0100
Message-Id: <1330602103-8851-2-git-send-email-jack@suse.cz>
In-Reply-To: <1330602103-8851-1-git-send-email-jack@suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jan Kara <jack@suse.cz>, Jaya Kumar <jayalk@intworks.biz>

CC: Jaya Kumar <jayalk@intworks.biz>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/video/fb_defio.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/video/fb_defio.c b/drivers/video/fb_defio.c
index c27e153..7a09c06 100644
--- a/drivers/video/fb_defio.c
+++ b/drivers/video/fb_defio.c
@@ -104,6 +104,8 @@ static int fb_deferred_io_mkwrite(struct vm_area_struct *vma,
 	deferred framebuffer IO. then if userspace touches a page
 	again, we repeat the same scheme */
 
+	file_update_time(vma->vm_file);
+
 	/* protect against the workqueue changing the page list */
 	mutex_lock(&fbdefio->lock);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
