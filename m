Message-Id: <20080318185718.873571360@szeredi.hu>
References: <20080318185626.300130296@szeredi.hu>
Date: Tue, 18 Mar 2008 19:56:28 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 2/4] mm: bdi: export bdi_writeout_inc() fix
Content-Disposition: inline; filename=export_bdi_writeout_inc_fix.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make bdi_writeout_inc() GPL only at the request of Peter Zijlstra.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2008-03-18 19:38:45.000000000 +0100
+++ linux/mm/page-writeback.c	2008-03-18 19:39:51.000000000 +0100
@@ -176,7 +176,7 @@ void bdi_writeout_inc(struct backing_dev
 	__bdi_writeout_inc(bdi);
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(bdi_writeout_inc);
+EXPORT_SYMBOL_GPL(bdi_writeout_inc);
 
 static inline void task_dirty_inc(struct task_struct *tsk)
 {

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
