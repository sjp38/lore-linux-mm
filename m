Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 13F156B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 07:15:59 -0400 (EDT)
Date: Wed, 4 May 2011 19:15:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/2] writeback: elevate queue_io() into wb_writeback()
Message-ID: <20110504111547.GA5441@localhost>
References: <20110426144218.GA14862@localhost>
 <20110426144402.GA15166@localhost>
 <20110504110849.GC4646@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504110849.GC4646@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, May 04, 2011 at 07:08:49PM +0800, Christoph Hellwig wrote:
> >  	return 1;
> >  }
> >  
> > -void writeback_inodes_wb(struct bdi_writeback *wb,
> > -		struct writeback_control *wbc)
> > +static void __writeback_inodes_wb(struct bdi_writeback *wb,
> > +				  struct writeback_control *wbc)
> >  {
> >  	int ret = 0;
> >  
> >  	if (!wbc->wb_start)
> >  		wbc->wb_start = jiffies; /* livelock avoidance */
> 
> This should move to writeback_inodes_wb and be unconditional as
> wb_writeback already always initializes it.

Never mind :) wbc->wb_start has been killed in a later patch named
"writeback: avoid extra sync work at enqueue time".

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
