Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 4F9316B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:46:49 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 02/11] fb_defio: Push file_update_time() into fb_deferred_io_mkwrite()
Date: Thu, 16 Feb 2012 14:46:10 +0100
Message-Id: <1329399979-3647-3-git-send-email-jack@suse.cz>
In-Reply-To: <1329399979-3647-1-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jaya Kumar <jayalk@intworks.biz>

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
