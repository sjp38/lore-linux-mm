From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 25 Aug 2006 17:38:12 +0200
Message-Id: <20060825153812.24254.9718.sendpatchset@twins>
In-Reply-To: <20060825153709.24254.28118.sendpatchset@twins>
References: <20060825153709.24254.28118.sendpatchset@twins>
Subject: [PATCH 6/6] nfs: Enable swap over NFS
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

Now that NFS can handle swap cache pages, add a swapfile method to allow
swapping over NFS.

NOTE: this dummy method is obviously not enough to make it safe.
A more complete version of the nfs_swapfile() function will be present
in the next VM deadlock avoidance patches.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/file.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c
+++ linux-2.6/fs/nfs/file.c
@@ -315,6 +315,11 @@ static int nfs_release_page(struct page 
 	return !nfs_wb_page(page_file_mapping(page)->host, page);
 }
 
+static int nfs_swapfile(struct address_space *mapping, int enable)
+{
+	return 0;
+}
+
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -328,6 +333,7 @@ const struct address_space_operations nf
 #ifdef CONFIG_NFS_DIRECTIO
 	.direct_IO = nfs_direct_IO,
 #endif
+	.swapfile = nfs_swapfile,
 };
 
 /* 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
