Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 720DF6B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 16:55:41 -0400 (EDT)
Date: Thu, 21 Jul 2011 13:55:37 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -next] mm/truncate.c: fix build for CONFIG_BLOCK not enabled
Message-Id: <20110721135537.dbfea947.rdunlap@xenotime.net>
In-Reply-To: <20110718152117.GA8844@infradead.org>
References: <20110718203501.232bd176e83ff65f056366e6@canb.auug.org.au>
	<20110718081816.2106117e.rdunlap@xenotime.net>
	<20110718152117.GA8844@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix build error when CONFIG_BLOCK is not enabled by providing a stub
inode_dio_wait() function.

mm/truncate.c:612: error: implicit declaration of function 'inode_dio_wait'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 include/linux/fs.h |    4 ++++
 1 file changed, 4 insertions(+)

--- linux-next-20110721.orig/include/linux/fs.h
+++ linux-next-20110721/include/linux/fs.h
@@ -2418,6 +2418,10 @@ static inline ssize_t blockdev_direct_IO
 				    offset, nr_segs, get_block, NULL, NULL,
 				    DIO_LOCKING | DIO_SKIP_HOLES);
 }
+#else
+static inline void inode_dio_wait(struct inode *inode)
+{
+}
 #endif
 
 extern const struct file_operations generic_ro_fops;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
