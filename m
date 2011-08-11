Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 102326B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 17:00:20 -0400 (EDT)
Date: Thu, 11 Aug 2011 17:00:08 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/5] IO-less dirty throttling v8
Message-ID: <20110811210008.GI8552@redhat.com>
References: <20110806084447.388624428@intel.com>
 <20110809020127.GA3700@redhat.com>
 <20110811032143.GB11404@localhost>
 <20110811204255.GH8552@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110811204255.GH8552@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 11, 2011 at 04:42:55PM -0400, Vivek Goyal wrote:

[..]
> So I see following immediate extension of your scheme possible.
> 
> - Inherit ioprio from iocontext and provide buffered write service
>   differentiation for writers.
> 
> - Create a per task buffered write throttling interface and do
>   absolute throttling of task.
> 
> - We can possibly do the idea of throttling group wide buffered
>   writes only control at this layer using this mechanism.

Though personally I like the idea of absolute throttling at page cache
level as it can help a bit with problem of buffered WRITES impacting
the latency of everything else in the system. CFQ helps a lot but
it idles enough that cost of this isolation is very high on faster
storage.

Deadline and noop really do not do much about protection from WRITEs.

So it is not perfect but might prove to be good enough for some use
cases.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
