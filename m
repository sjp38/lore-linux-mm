Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D8EA86B018E
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 11:22:10 -0400 (EDT)
Date: Mon, 1 Nov 2010 11:21:50 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] writeback: integrated background writeback work
Message-ID: <20101101152149.GA12741@infradead.org>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
 <20101101121408.GB9006@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101101121408.GB9006@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> +static void _bdi_wakeup_flusher(struct backing_dev_info *bdi)

Remove the leading underscore, please.

>  void bdi_start_background_writeback(struct backing_dev_info *bdi)
>  {
> -	__bdi_start_writeback(bdi, LONG_MAX, true, true);
> +	/*
> +	 * We just wake up the flusher thread. It will perform background
> +	 * writeback as soon as there is no other work to do.
> +	 */
> +	spin_lock_bh(&bdi->wb_lock);
> +	_bdi_wakeup_flusher(bdi);
> +	spin_unlock_bh(&bdi->wb_lock);

We probably want a trace point here, too.

Otherwise the patch looks good to me.  Thanks for bringing it up again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
