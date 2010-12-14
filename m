Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F20D46B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 23:59:53 -0500 (EST)
Date: Tue, 14 Dec 2010 12:59:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/35] IO-less dirty throttling v4
Message-ID: <20101214045948.GA12454@localhost>
References: <20101213144646.341970461@intel.com>
 <AANLkTinFeu7LMaDFgUcP3r2oqVHE5bei3T5JTPGBNvS9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinFeu7LMaDFgUcP3r2oqVHE5bei3T5JTPGBNvS9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: "Yan, Zheng" <zheng.z.yan@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Wu, Fengguang" <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 11:26:29AM +0800, Yan, Zheng wrote:
> got error "global_dirty_limits" [fs/nfs/nfs.ko] undefined! when
> compiling dirty-throttling-v4

Thanks! This should fix it. The fix will show up in the git tree after a while.

Thanks,
Fengguang
---
Subject: writeback: export global_dirty_limits() for NFS
Date: Tue Dec 14 12:55:18 CST 2010

"global_dirty_limits" [fs/nfs/nfs.ko] undefined!

Reported-by: Yan Zheng <zheng.z.yan@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next.orig/mm/page-writeback.c	2010-12-14 12:54:57.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-14 12:55:11.000000000 +0800
@@ -419,6 +419,7 @@ void global_dirty_limits(unsigned long *
 	*pbackground = background;
 	*pdirty = dirty;
 }
+EXPORT_SYMBOL_GPL(global_dirty_limits);
 
 /**
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
