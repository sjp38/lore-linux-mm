Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8BD0F6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 18:47:46 -0400 (EDT)
Date: Tue, 9 Aug 2011 06:47:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110808224742.GB7176@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312813909.10488.38.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312813909.10488.38.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 08, 2011 at 10:31:49PM +0800, Peter Zijlstra wrote:
> On Mon, 2011-08-08 at 22:11 +0800, Wu Fengguang wrote:
> > It's actually dead code because (origin < limit) should never happen.
> > I feel so good being able to drop 5 more lines of code :) 
> 
> OK, but that leaves me trying to figure out what origin is, and why its
> 4 * thresh.

origin is where the control line crosses the X axis (in both the
global/bdi setpoint cases).

"4 * thresh" is merely something larger than max(dirty, thresh)
that yields reasonably gentle slope. The more slope, the larger
"gravity" to bring the dirty pages back to the setpoint.

> I'm having a horrible time understanding this stuff.

Sorry for that. Do you have more questions?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
