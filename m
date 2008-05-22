Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4MNuq5U008661
	for <linux-mm@kvack.org>; Thu, 22 May 2008 19:56:52 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4MNsTdC093770
	for <linux-mm@kvack.org>; Thu, 22 May 2008 19:54:29 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4MNsT9g003856
	for <linux-mm@kvack.org>; Thu, 22 May 2008 19:54:29 -0400
Date: Thu, 22 May 2008 16:54:27 -0700
From: Tim Pepper <lnxninja@linux.vnet.ibm.com>
Subject: [PATCH] mm: fix filemap.c's comment re: buffer_head.h inclusion
	reason
Message-ID: <20080522235426.GA28518@tpepper-t42p.dolavim.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It appears mm/filemap.c's comment on why buffer_head.h is included has
gotten out of date.  Today generic_osync_inode() is coming from the fs.h
include and buffer_head.h is providing try_to_free_buffers().

Signed-off-by: Tim Pepper <lnxninja@linux.vnet.ibm.com>
Cc:            linux-mm@kvack.org

---

diff --git a/mm/filemap.c b/mm/filemap.c
index 1e6a7d3..fe4adf4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -38,7 +38,7 @@
 /*
  * FIXME: remove all knowledge of the buffer layer from the core VM
  */
-#include <linux/buffer_head.h> /* for generic_osync_inode */
+#include <linux/buffer_head.h> /* for try_to_free_buffers */
 
 #include <asm/mman.h>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
