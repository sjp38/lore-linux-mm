Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B852D6B0089
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 11:27:00 -0500 (EST)
Date: Wed, 10 Nov 2010 17:26:55 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/5] writeback: stop background/kupdate works from
 livelocking other works
Message-ID: <20101110162655.GA4999@quack.suse.cz>
References: <20101110023500.404859581@intel.com>
 <20101110024223.847210776@intel.com>
 <20101110035516.GA12710@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110035516.GA12710@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed 10-11-10 11:55:16, Wu Fengguang wrote:
> Jan, the below comment is also updated, please double check.
  Thanks! The comment looks OK.

> >  		/*
> > +		 * Background writeout and kupdate-style writeback may
> > +		 * run forever. Stop them if there is other work to do
> > +		 * so that e.g. sync can proceed. They'll be restarted
> > +		 * after the other works are all done.
> > +		 */
> > +		if ((work->for_background || work->for_kupdate) &&
> > +		    !list_empty(&wb->bdi->work_list))
> > +			break;
> > +
> > +		/*
> >  		 * For background writeout, stop when we are below the
> >  		 * background dirty threshold
> >  		 */

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
