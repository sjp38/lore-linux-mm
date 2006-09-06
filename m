Message-Id: <20060906133954.023622000@chello.nl>
References: <20060906131630.793619000@chello.nl>>
Date: Wed, 06 Sep 2006 15:16:37 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 07/21] nfs: add a comment explaining the use of PG_private in the NFS client
Content-Disposition: inline; filename=nfs_PG_private_comment.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

---
 fs/nfs/write.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -424,6 +424,11 @@ static int nfs_inode_add_request(struct 
 		if (nfs_have_delegation(inode, FMODE_WRITE))
 			nfsi->change_attr++;
 	}
+	/*
+	 * The PG_private bit is unfortunately needed if we want to fix the
+	 * hole in the mmap semantics. If we do not set it, then the VM will
+	 * fail to call the "releasepage" address ops.
+	 */
 	SetPagePrivate(req->wb_page);
 	nfsi->npages++;
 	atomic_inc(&req->wb_count);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
