Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE2F66B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:32:14 -0400 (EDT)
Received: by wyf19 with SMTP id 19so6540090wyf.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 06:32:12 -0700 (PDT)
Date: Tue, 24 May 2011 15:32:05 +0200
From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH] Delete unused variable no_wb.
Message-ID: <20110524133204.GA11529@nb-core2.darkstar.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>

The number of writeback threads was removed from the output by c1955ce3.

Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
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
