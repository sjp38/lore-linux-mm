Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C4F156B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 11:10:46 -0400 (EDT)
Date: Wed, 27 Jul 2011 11:10:35 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Properly reflect task dirty limits in dirty_exceeded
 logic
Message-ID: <20110727151035.GA17113@infradead.org>
References: <1309458764-9153-1-git-send-email-jack@suse.cz>
 <20110704010618.GA3841@localhost>
 <20110711170605.GF5482@quack.suse.cz>
 <20110713230258.GA17011@localhost>
 <20110714213409.GB16415@quack.suse.cz>
 <20110723074344.GA31975@localhost>
 <20110725160429.GG6107@quack.suse.cz>
 <20110726041322.GA22180@localhost>
 <20110726135730.GD20131@quack.suse.cz>
 <20110727140440.GA14312@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110727140440.GA14312@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, Jul 27, 2011 at 10:04:41PM +0800, Wu Fengguang wrote:
> > > to pull that branch.
> >   Umm, I thought we ultimately still push changes through Andrew? I don't
> > mind pushing them directly but I'm not sure e.g. Andrew is aware of this.
> 
> I'll happily send patches to Andrew Morton if he would like to take
> care of the mess :) In particular Andrew should still carry the
> writeback changes that may interact or conflict with the -mm tree.

I have to say that I'd really like to keep the writeback tree as it is
right now.  We have a tree that has all the changes, goes in -next and
gets merged right like it was in -next.  That's the canonical model used
for all other normal trees, and it works extremely well.

> Sorry I overlooked the Acked-by/Reviewed-by principle, which is
> definitely good practice to follow. However given that Linus has
> merged the patches and they do look like pretty safe changes, we may
> consider watch and improve the algorithms based on them.

Yes, absolutely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
