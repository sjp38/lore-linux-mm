Date: Tue, 8 Jul 2008 11:38:12 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 2/2] - Unmap driver ptes - GRU 
Message-ID: <20080708163812.GA20127@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Change the GRU driver to use the new zap_vma_ptes() interface.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 drivers/misc/sgi-gru/grumain.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/drivers/misc/sgi-gru/grumain.c
===================================================================
--- linux.orig/drivers/misc/sgi-gru/grumain.c	2008-07-07 12:16:23.000000000 -0500
+++ linux/drivers/misc/sgi-gru/grumain.c	2008-07-07 12:21:14.321933793 -0500
@@ -489,7 +489,7 @@ void gru_unload_context(struct gru_threa
 	struct gru_context_configuration_handle *cch;
 	int ctxnum = gts->ts_ctxnum;
 
-	zap_page_range(gts->ts_vma, UGRUADDR(gts), GRU_GSEG_PAGESIZE, NULL);
+	zap_vma_ptes(gts->ts_vma, UGRUADDR(gts), GRU_GSEG_PAGESIZE);
 	cch = get_cch(gru->gs_gru_base_vaddr, ctxnum);
 
 	lock_cch_handle(cch);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
