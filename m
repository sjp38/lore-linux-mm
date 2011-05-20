Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFEE8D003B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 15:13:27 -0400 (EDT)
Received: by qyk2 with SMTP id 2so571489qyk.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 12:13:26 -0700 (PDT)
From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: [PATCH 1/8] mm: Kill set but not used var in  bdi_debug_stats_show()
Date: Fri, 20 May 2011 16:12:58 -0300
Message-Id: <1305918786-7239-1-git-send-email-padovan@profusion.mobi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@lst.de>, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
---
 mm/backing-dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index befc875..f032e6e 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -63,10 +63,10 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-	unsigned long nr_dirty, nr_io, nr_more_io, nr_wb;
+	unsigned long nr_dirty, nr_io, nr_more_io;
 	struct inode *inode;
 
-	nr_wb = nr_dirty = nr_io = nr_more_io = 0;
+	nr_dirty = nr_io = nr_more_io = 0;
 	spin_lock(&inode_wb_list_lock);
 	list_for_each_entry(inode, &wb->b_dirty, i_wb_list)
 		nr_dirty++;
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
