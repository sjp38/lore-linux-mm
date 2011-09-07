Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 05B4B6B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 20:22:25 -0400 (EDT)
Date: Wed, 7 Sep 2011 02:22:22 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 17/18] writeback: fix dirtied pages accounting on
 redirty
Message-ID: <20110907002222.GF31945@quack.suse.cz>
References: <20110904015305.367445271@intel.com>
 <20110904020916.841463184@intel.com>
 <1315325936.14232.22.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315325936.14232.22.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 06-09-11 18:18:56, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > De-account the accumulative dirty counters on page redirty.
> > 
> > Page redirties (very common in ext4) will introduce mismatch between
> > counters (a) and (b)
> > 
> > a) NR_DIRTIED, BDI_DIRTIED, tsk->nr_dirtied
> > b) NR_WRITTEN, BDI_WRITTEN
> > 
> > This will introduce systematic errors in balanced_rate and result in
> > dirty page position errors (ie. the dirty pages are no longer balanced
> > around the global/bdi setpoints).
> > 
> 
> So wtf is ext4 doing? Shouldn't a page stay dirty until its written out?
> 
> That is, should we really frob around this behaviour or fix ext4 because
> its on crack?
  Fengguang, could you please verify your findings with recent kernel? I
believe ext4 got fixed in this regard some time ago already (and yes, old
delalloc writeback code in ext4 was terrible).

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
