Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F6CB6B008C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 06:49:21 -0500 (EST)
Date: Mon, 13 Dec 2010 19:49:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/47] IO-less dirty throttling v3
Message-ID: <20101213114911.GA2232@localhost>
References: <20101213064249.648862451@intel.com>
 <1292239631.6803.186.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1292239631.6803.186.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 13, 2010 at 07:27:11PM +0800, Peter Zijlstra wrote:
> On Mon, 2010-12-13 at 14:42 +0800, Wu Fengguang wrote:
> > bdi dirty limit fixes
> >         [PATCH 01/47] writeback: enabling gate limit for light dirtied bdi
> >         [PATCH 02/47] writeback: safety margin for bdi stat error
> > 
> > v2 patches rebased onto the above two fixes
> >         [PATCH 03/47] writeback: IO-less balance_dirty_pages()
> >         [PATCH 04/47] writeback: consolidate variable names in balance_dirty_pages()
> >         [PATCH 05/47] writeback: per-task rate limit on balance_dirty_pages()
> >         [PATCH 06/47] writeback: prevent duplicate balance_dirty_pages_ratelimited() calls
> >         [PATCH 07/47] writeback: account per-bdi accumulated written pages
> >         [PATCH 08/47] writeback: bdi write bandwidth estimation
> >         [PATCH 09/47] writeback: show bdi write bandwidth in debugfs
> >         [PATCH 10/47] writeback: quit throttling when bdi dirty pages dropped low
> >         [PATCH 11/47] writeback: reduce per-bdi dirty threshold ramp up time
> >         [PATCH 12/47] writeback: make reasonable gap between the dirty/background thresholds
> >         [PATCH 13/47] writeback: scale down max throttle bandwidth on concurrent dirtiers
> >         [PATCH 14/47] writeback: add trace event for balance_dirty_pages()
> >         [PATCH 15/47] writeback: make nr_to_write a per-file limit
> > 
> > trivial fixes for v2
> >         [PATCH 16/47] writeback: make-nr_to_write-a-per-file-limit fix
> >         [PATCH 17/47] writeback: do uninterruptible sleep in balance_dirty_pages()
> >         [PATCH 18/47] writeback: move BDI_WRITTEN accounting into __bdi_writeout_inc()
> >         [PATCH 19/47] writeback: fix increasement of nr_dirtied_pause
> >         [PATCH 20/47] writeback: use do_div in bw calculation
> >         [PATCH 21/47] writeback: prevent divide error on tiny HZ
> >         [PATCH 22/47] writeback: prevent bandwidth calculation overflow
> > 
> > spinlock protected bandwidth estimation, as suggested by Peter
> >         [PATCH 23/47] writeback: spinlock protected bdi bandwidth update
> > 
> > algorithm updates
> >         [PATCH 24/47] writeback: increase pause time on concurrent dirtiers
> >         [PATCH 25/47] writeback: make it easier to break from a dirty exceeded bdi
> >         [PATCH 26/47] writeback: start background writeback earlier
> >         [PATCH 27/47] writeback: user space think time compensation
> >         [PATCH 28/47] writeback: bdi base throttle bandwidth
> >         [PATCH 29/47] writeback: smoothed bdi dirty pages
> >         [PATCH 30/47] writeback: adapt max balance pause time to memory size
> >         [PATCH 31/47] writeback: increase min pause time on concurrent dirtiers 
> 
> I would think it would be easier for review to fold all this back into
> sensible patches.
> 
> Reviewing is lots easier if the patches present logical steps. The
> presented series will have us looking back and forth, review patch, find
> bugs, then scan fwd to see if the bug has been solved, etc..

Good suggestion. Sorry I did have the plan to fold them at some later
time.  I'll do a new version to fold the patches 16-25.  26-31 will be
retained since they are logical enhancements that do not involve
back-and-forth changes. 12 will be removed as it seems not absolutely
necessary -- let the users do whatever they feel OK, even if it means
make the throttling algorithms work in some suboptimal condition.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
