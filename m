Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B73956B00CA
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 21:55:37 -0400 (EDT)
Date: Mon, 13 Sep 2010 09:55:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 05/17] writeback: quit throttling when signal pending
Message-ID: <20100913015529.GB5312@localhost>
References: <20100912154945.758129106@intel.com>
 <20100912155203.355459925@intel.com>
 <20100913064654.3cce885c@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100913064654.3cce885c@notabene>
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 04:46:54AM +0800, Neil Brown wrote:
> On Sun, 12 Sep 2010 23:49:50 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > This allows quick response to Ctrl-C etc. for impatient users.
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/page-writeback.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > --- linux-next.orig/mm/page-writeback.c	2010-09-09 16:01:14.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2010-09-09 16:02:27.000000000 +0800
> > @@ -553,6 +553,9 @@ static void balance_dirty_pages(struct a
> >  		__set_current_state(TASK_INTERRUPTIBLE);
> >  		io_schedule_timeout(pause);
> >  
> > +		if (signal_pending(current))
> > +			break;
> > +
> 
> Given the patch description,  I think you might want "fatal_signal_pending()"
> here ???

__fatal_signal_pending() tests SIGKILL only, while the one often used
and need more quick responding is SIGINT..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
