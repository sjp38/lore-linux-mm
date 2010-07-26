Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DDF946006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 07:33:17 -0400 (EDT)
Date: Mon, 26 Jul 2010 19:32:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/6] writeback: the kupdate expire timestamp should be
 a moving target
Message-ID: <20100726113245.GC6284@localhost>
References: <20100722050928.653312535@intel.com>
 <20100722061822.630779474@intel.com>
 <20100726105200.GK5300@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100726105200.GK5300@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 06:52:00PM +0800, Mel Gorman wrote:
> On Thu, Jul 22, 2010 at 01:09:30PM +0800, Wu Fengguang wrote:
> > Dynamicly compute the dirty expire timestamp at queue_io() time.
> > Also remove writeback_control.older_than_this which is no longer used.
> > 
> > writeback_control.older_than_this used to be determined at entrance to
> > the kupdate writeback work. This _static_ timestamp may go stale if the
> > kupdate work runs on and on. The flusher may then stuck with some old
> > busy inodes, never considering newly expired inodes thereafter.
> > 
> > This has two possible problems:
> > 
> > - It is unfair for a large dirty inode to delay (for a long time) the
> >   writeback of small dirty inodes.
> > 
> > - As time goes by, the large and busy dirty inode may contain only
> >   _freshly_ dirtied pages. Ignoring newly expired dirty inodes risks
> >   delaying the expired dirty pages to the end of LRU lists, triggering
> >   the very bad pageout(). Neverthless this patch merely addresses part
> >   of the problem.
> > 
> > CC: Jan Kara <jack@suse.cz>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Again, makes sense and I can't see a problem. There are some worth
> smithing issues in the changelog such as Dynamicly -> Dynamically and

Hah forgot to enable spell checking.

> s/writeback_control.older_than_this used/writeback_control.older_than_this is used/

It's "used to", my god.

> but other than that.
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
