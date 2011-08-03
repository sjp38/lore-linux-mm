Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C9A566B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 10:00:36 -0400 (EDT)
Date: Wed, 3 Aug 2011 16:00:19 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 3/8] ext4: Warn if direct reclaim tries to writeback pages
Message-ID: <20110803140019.GA31026@redhat.com>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-4-git-send-email-mgorman@suse.de>
 <20110803105819.GA27199@redhat.com>
 <20110803110629.GB27199@redhat.com>
 <20110803134420.GH19099@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110803134420.GH19099@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, Aug 03, 2011 at 02:44:20PM +0100, Mel Gorman wrote:
> On Wed, Aug 03, 2011 at 01:06:29PM +0200, Johannes Weiner wrote:
> > On Wed, Aug 03, 2011 at 12:58:19PM +0200, Johannes Weiner wrote:
> > > On Thu, Jul 21, 2011 at 05:28:45PM +0100, Mel Gorman wrote:
> > > > Direct reclaim should never writeback pages. Warn if an attempt
> > > > is made.
> > > > 
> > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > 
> > > Acked-by: Johannes Weiner <jweiner@redhat.com>
> > 
> > Oops, too fast.
> > 
> > Shouldn't the WARN_ON() be at the top of the function, rather than
> > just warn when the write is deferred due to delalloc?
> 
> I thought it made more sense to put the warning at the point where ext4
> would normally ignore ->writepage.
> 
> That said, in my current revision of the series, I've dropped these
> patches altogether as page migration should be able to trigger the same
> warnings but be called from paths that are of less concern for stack
> overflows (or at the very least be looked at as a separate series).

Doesn't this only apply to btrfs which has no own .migratepage aop for
file pages?  The others use buffer_migrate_page.

But if you dropped them anyway, it does not matter :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
