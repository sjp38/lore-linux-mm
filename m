Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 92A766B00EE
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 15:16:38 -0400 (EDT)
Date: Tue, 9 Aug 2011 15:16:22 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110809191622.GH6482@redhat.com>
References: <20110806084447.388624428@intel.com>
 <20110806094527.136636891@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110806094527.136636891@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Aug 06, 2011 at 04:44:52PM +0800, Wu Fengguang wrote:

[..]
> -/*
> - * task_dirty_limit - scale down dirty throttling threshold for one task
> - *
> - * task specific dirty limit:
> - *
> - *   dirty -= (dirty/8) * p_{t}
> - *
> - * To protect light/slow dirtying tasks from heavier/fast ones, we start
> - * throttling individual tasks before reaching the bdi dirty limit.
> - * Relatively low thresholds will be allocated to heavy dirtiers. So when
> - * dirty pages grow large, heavy dirtiers will be throttled first, which will
> - * effectively curb the growth of dirty pages. Light dirtiers with high enough
> - * dirty threshold may never get throttled.
> - */

Hi Fengguang,

So we have got rid of the notion of per task dirty limit based on their
fraction? What replaces it.

I can't see any code which is replacing it. If yes, I am wondering how
do you get fairness among tasks which share this bdi.

Also wondering what did this patch series to do make sure that tasks
share bdi more fairly and get write_bw/N bandwidth.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
