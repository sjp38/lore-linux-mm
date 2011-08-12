Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 57EAA900137
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 07:11:44 -0400 (EDT)
Date: Fri, 12 Aug 2011 19:11:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110812111139.GB8016@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313103367.26866.39.camel@twins>
 <20110812024353.GA11606@localhost>
 <1313142474.6576.10.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313142474.6576.10.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 12, 2011 at 05:47:54PM +0800, Peter Zijlstra wrote:
> On Fri, 2011-08-12 at 10:43 +0800, Wu Fengguang wrote:
> > >                s - x 3
> > >  f(x) :=  1 + (-----)
> > >                l - s
> > 
> 
> > Looks very neat, much simpler than the three curves solution!
> 
> Glad you like it, there is of course the small matter of real-world
> behaviour to consider, lets hope that works as well :-)

It magically meets all the criteria in my mind, not to mention it can
eliminate 2 extra patches. As for the tests, so far, so good :)

Your arithmetics are awesome!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
