Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD18900138
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 09:00:00 -0400 (EDT)
Date: Fri, 12 Aug 2011 20:59:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110812125952.GA16675@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313153657.6576.40.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313153657.6576.40.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 12, 2011 at 08:54:17PM +0800, Peter Zijlstra wrote:
> On Fri, 2011-08-12 at 00:56 +0200, Peter Zijlstra wrote:
> > 
> >                s - x 3
> >  f(x) :=  1 + (-----)
> >                  d
> > 
> btw, if you want steeper slopes for rampup and brake you can add another
> factor like:
> 
>                  s - x 3
>   f(x) :=  1 + a(-----)
>                    d
>  
> And solve the whole f(l)=0 thing again to determine d in l and a.
> 
> For 0 < a < 1 the slopes increase.

Yes, we can leave it as a future tuning option. For now I'm pretty
satisfied with the current function's shape :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
