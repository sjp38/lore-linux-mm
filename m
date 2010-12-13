From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 16/47] writeback: make-nr_to_write-a-per-file-limit fix
Date: Mon, 13 Dec 2010 14:43:05 +0800
Message-ID: <20101213064838.908880749@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Ej-0005aE-Kx
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:17 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BCCAD6B0092
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-make-nr_to_write-a-per-file-limit-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Li Shaohua <shaohua.li@intel.com>, Mel Gorman <mel@csn.ul.ie>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Rik van Riel <riel@redhat.com>, Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

From: Andrew Morton <akpm@linux-foundation.org>

older gcc's are dumb:

fs/fs-writeback.c: In function 'writeback_single_inode':
fs/fs-writeback.c:334: warning: 'nr_to_write' may be used uninitialized in this function

Cc: Chris Mason <chris.mason@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Li Shaohua <shaohua.li@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Rik van Riel <riel@redhat.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
LKML-Reference: <201011180023.oAI0NXFl014362@imap1.linux-foundation.org>
---
 fs/fs-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/fs/fs-writeback.c	2010-12-08 22:44:26.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-12-08 22:44:27.000000000 +0800
@@ -331,7 +331,7 @@ writeback_single_inode(struct inode *ino
 {
 	struct address_space *mapping = inode->i_mapping;
 	long per_file_limit = wbc->per_file_limit;
-	long nr_to_write;
+	long uninitialized_var(nr_to_write);
 	unsigned dirty;
 	int ret;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
