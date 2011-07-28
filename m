Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 687F36B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 11:31:57 -0400 (EDT)
Date: Thu, 28 Jul 2011 17:31:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Properly reflect task dirty limits in
 dirty_exceeded logic
Message-ID: <20110728153150.GE5044@quack.suse.cz>
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

On Wed 27-07-11 22:04:41, Wu Fengguang wrote:
> On Tue, Jul 26, 2011 at 09:57:30PM +0800, Jan Kara wrote:
> > On iue 26-07-11 12:13:22, Wu Fengguang wrote:
> > f7d2b1e writeback: account per-bdi accumulated written pages
> > e98be2d writeback: bdi write bandwidth estimation
> > 00821b0 writeback: show bdi write bandwidth in debugfs
> > 7762741 writeback: consolidate variable names in balance_dirty_pages()
> > c42843f writeback: introduce smoothed global dirty limit
> > ffd1f60 writeback: introduce max-pause and pass-good dirty limits
> > e1cbe23 writeback: trace global_dirty_state
> > 1a12d8b writeback: scale IO chunk size up to half device bandwidth
> > 
> > But why do you think these patches should be merged? f7d2b1e, 7762741 are
> > probably OK to go but don't have much sense without the rest. The other
> > patches do not have any Acked-by or Reviewed-by from anyone and I don't
> > think they are really obvious enough to not deserve some.
> 
> Sorry I overlooked the Acked-by/Reviewed-by principle, which is
> definitely good practice to follow. However given that Linus has
> merged the patches and they do look like pretty safe changes, we may
> consider watch and improve the algorithms based on them.
  :-| Well, at least c42843f and 1a12d8b do not look "pretty safe" to me.
But when it already happened, let's work with what we have.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
