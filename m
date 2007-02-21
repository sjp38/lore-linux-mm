Message-Id: <20070221144843.989983000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:29 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 25/29] nfs: only use stable storage for swap
Content-Disposition: inline; filename=nfs-wb_priority.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

unstable writes don't make sense for swap pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/nfs/write.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-git/fs/nfs/write.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/write.c	2007-02-21 12:15:10.000000000 +0100
+++ linux-2.6-git/fs/nfs/write.c	2007-02-21 12:15:13.000000000 +0100
@@ -197,7 +197,7 @@ static int nfs_writepage_setup(struct nf
 static int wb_priority(struct writeback_control *wbc)
 {
 	if (wbc->for_reclaim)
-		return FLUSH_HIGHPRI;
+		return FLUSH_HIGHPRI|FLUSH_STABLE;
 	if (wbc->for_kupdate)
 		return FLUSH_LOWPRI;
 	return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
