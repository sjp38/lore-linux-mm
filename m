Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C710F6B006C
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 11:14:06 -0400 (EDT)
Date: Wed, 2 Nov 2011 23:13:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: writeback tree status (for 3.2 merge window)
Message-ID: <20111102151355.GA6717@localhost>
References: <20111101074347.GA23644@localhost>
 <20111102091012.GA25879@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111102091012.GA25879@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Curt Wohlgemuth <curtw@google.com>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tang Feng <feng.tang@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, xfs@oss.sgi.com

On Wed, Nov 02, 2011 at 05:10:12AM -0400, Christoph Hellwig wrote:
> On Tue, Nov 01, 2011 at 03:43:47PM +0800, Wu Fengguang wrote:
> > Hi,
> > 
> > There are 3 patchsets sitting in the writeback tree.
> > 
> >         1) IO-less dirty throttling v12
> >         https://github.com/fengguang/linux/commits/dirty-throttling-v12
> > 
> >         2) writeback reasons tracing from Curt Wohlgemuth
> >         https://github.com/fengguang/linux/commits/writeback-reason
> > 
> >         3) writeback queuing changes from Jan Kara and me
> >         https://github.com/fengguang/linux/commits/requeue-io-wait
> > 
> > They have been merged into this branch testing in linux-next for a while:
> > 
> > https://github.com/fengguang/linux/commits/writeback-for-next
> > 
> > Since (3) still has an unresolved issue (detailed in the below
> > links), it looks better to hold it back for this merge window.
> 
> Given that we have run into issues so much with it that's proably
> the better idea.
> 
> To fix the originally reported issue with the missing file size updates
> in XFS we plan to simply log all filesize changes in XFS.  Currently I
> had this in the 3.3 queue, but in the worst case we might have to move
> this forward to 3.2.

OK. Anyway I'll report any progress early on (3).

> > The patches from (1,2) together with 2 tracing patches essential for
> > debugging (1) have been pushed to the "writeback-for-linus" branch:
> > 
> >         http://git.kernel.org/?p=linux/kernel/git/wfg/linux.git;a=shortlog;h=refs/heads/writeback-for-linus
> > 
> > If no objections, I'll send a pull request to Linus soon.
> 
> Please do so.  I'm really looking forward to see the I/O-less
> balance_dirty_pages in ASAP.

Done, thanks!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
