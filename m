Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 609A36B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 09:48:53 -0400 (EDT)
Date: Mon, 15 Aug 2011 21:48:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
Message-ID: <20110815134846.GB13534@localhost>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
 <1313189245-7197-2-git-send-email-curtw@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313189245-7197-2-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Curt,

Some thoughts about the interface..before dipping into the code.

On Sat, Aug 13, 2011 at 06:47:25AM +0800, Curt Wohlgemuth wrote:
> Add a new file, /proc/writeback/stats, which displays

That's creating a new top directory in /proc. Do you have plans for
adding more files under it?

> machine global data for how many pages were cleaned for
> which reasons.  It also displays some additional counts for
> various writeback events.
> 
> These data are also available for each BDI, in
> /sys/block/<device>/bdi/writeback_stats .

> Sample output:
> 
>    page: balance_dirty_pages           2561544
>    page: background_writeout              5153
>    page: try_to_free_pages                   0
>    page: sync                                0
>    page: kupdate                        102723
>    page: fdatawrite                    1228779
>    page: laptop_periodic                     0
>    page: free_more_memory                    0
>    page: fs_free_space                       0
>    periodic writeback                      377
>    single inode wait                         0
>    writeback_wb wait                         1

That's already useful data, and could be further extended (in
future patches) to answer questions like "what's the writeback
efficiency in terms of effective chunk size?"

So in future there could be lines like

    pages: balance_dirty_pages           2561544
    chunks: balance_dirty_pages          XXXXXXX
    works: balance_dirty_pages           XXXXXXX

or even derived lines like

    pages_per_chunk: balance_dirty_pages         XXXXXXX
    pages_per_work: balance_dirty_pages          XXXXXXX

Another question is, how can the display format be script friendly?
The current form looks not easily parse-able at least for "cut"..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
