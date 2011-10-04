Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C5399900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 15:52:41 -0400 (EDT)
Date: Tue, 4 Oct 2011 15:52:06 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111004195206.GG28306@redhat.com>
References: <20111003134228.090592370@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111003134228.090592370@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 03, 2011 at 09:42:28PM +0800, Wu Fengguang wrote:
> Hi,
> 
> This is the minimal IO-less balance_dirty_pages() changes that are expected to
> be regression free (well, except for NFS).
> 
>         git://github.com/fengguang/linux.git dirty-throttling-v12
> 
> Tests results will be posted in a separate email.

Looks like we are solving two problems.

- IO less balance_dirty_pages()
- Throttling based on ratelimit instead of based on number of dirty pages.

The second piece is the one which has complicated calculations for
calculating the global/bdi rates and logic for stablizing the rates etc.

IIUC, second piece is primarily needed for better latencies for writers.

Will it make sense to break down this work in two patch series. First
push IO less balance dirty pages and then all the complicated pieces
of ratelimits.

ratelimit allowed you to come up with sleep time for the process. Without
that I think you shall have to fall back to what Jan Kar had done, 
calculation based on number of pages.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
