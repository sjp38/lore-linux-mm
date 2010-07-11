From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/6] writeback: take account of NR_WRITEBACK_TEMP in balance_dirty_pages()
Date: Sun, 11 Jul 2010 10:06:57 +0800
Message-ID: <20100711021748.594522648@intel.com>
References: <20100711020656.340075560@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-temp.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org


Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-07-11 08:41:37.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-07-11 08:42:14.000000000 +0800
@@ -503,11 +503,12 @@ static void balance_dirty_pages(struct a
 		};
 
 		get_dirty_limits(&background_thresh, &dirty_thresh,
-				&bdi_thresh, bdi);
+				 &bdi_thresh, bdi);
 
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+				 global_page_state(NR_UNSTABLE_NFS);
+		nr_writeback = global_page_state(NR_WRITEBACK) +
+			       global_page_state(NR_WRITEBACK_TEMP);
 
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);


