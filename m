Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 805DD6B00E8
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 09:47:06 -0400 (EDT)
Date: Tue, 14 Jun 2011 21:46:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: trace global_dirty_state
Message-ID: <20110614134655.GB13768@localhost>
References: <20110610144805.GA9986@localhost>
 <20110613143356.GG4907@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110613143356.GG4907@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 13, 2011 at 10:33:56PM +0800, Jan Kara wrote:
> On Fri 10-06-11 22:48:05, Wu Fengguang wrote:
> > [It seems beneficial to queue this simple trace event for
> >  next/upstream after the review?]
> > 
> > Add trace event balance_dirty_state for showing the global dirty page
> > counts and thresholds at each global_dirty_limits() invocation.  This
> > will cover the callers throttle_vm_writeout(), over_bground_thresh()
> > and each balance_dirty_pages() loop.
>   OK, this might be useful. But shouldn't we also add similar trace point
> for bdi limits? Otherwise the information is of limited use...

Good point. The bdi limits will be exported in another
balance_dirty_pages trace point.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
