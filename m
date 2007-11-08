Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA8JlW8Q013222
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:32 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA8JlWFR128894
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:32 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA8JlWmH002332
	for <linux-mm@kvack.org>; Thu, 8 Nov 2007 14:47:32 -0500
Date: Thu, 8 Nov 2007 14:47:31 -0500
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20071108194729.17862.36162.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
References: <20071108194709.17862.16713.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 03/09] Release tail when inode is freed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Release tail when inode is freed

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 fs/inode.c |    2 ++
 1 file changed, 2 insertions(+)

diff -Nurp linux002/fs/inode.c linux003/fs/inode.c
--- linux002/fs/inode.c	2007-11-08 10:49:46.000000000 -0600
+++ linux003/fs/inode.c	2007-11-08 10:49:46.000000000 -0600
@@ -10,6 +10,7 @@
 #include <linux/init.h>
 #include <linux/quotaops.h>
 #include <linux/slab.h>
+#include <linux/vm_file_tail.h>
 #include <linux/writeback.h>
 #include <linux/module.h>
 #include <linux/backing-dev.h>
@@ -260,6 +261,7 @@ void __iget(struct inode * inode)
 void clear_inode(struct inode *inode)
 {
 	might_sleep();
+	vm_file_tail_free(inode->i_mapping);
 	invalidate_inode_buffers(inode);
        
 	BUG_ON(inode->i_data.nrpages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
