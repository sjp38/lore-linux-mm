Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AD5EA6B016D
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 04:59:37 -0400 (EDT)
Date: Tue, 16 Aug 2011 16:59:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110816085932.GC19970@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <20110809020817.GB3700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809020817.GB3700@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > bdi_position_ratio() provides a scale factor to bdi->dirty_ratelimit, so
> > that the resulted task rate limit can drive the dirty pages back to the
> > global/bdi setpoints.
> > 
> 
> IMHO, "position_ratio" is not necessarily very intutive. Can there be
> a better name? Based on your slides, it is scaling factor applied to
> task rate limit depending on how well we are doing in terms of meeting
> our goal of dirty limit. Will "dirty_rate_scale_factor" or something like
> that make sense and be little more intutive? 

Yeah position_ratio is some scale factor to the dirty rate, and I
added a comment for that. On the other hand position_ratio does
reflect the underlying "position control of dirty pages" logic. So
over time it should be reasonably understandable in the other way :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
