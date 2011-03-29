Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6A38A8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:57:32 -0400 (EDT)
Date: Tue, 29 Mar 2011 12:57:27 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Very aggressive memory reclaim
Message-ID: <20110329015727.GE3008@dastard>
References: <AANLkTinFqqmE+fTMTLVU-_CwPE+LQv7CpXSQ5+CdAKLK@mail.gmail.com>
 <20110328215344.GC3008@dastard>
 <m2bp0u23wl.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2bp0u23wl.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: John Lepikhin <johnlepikhin@gmail.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 04:58:50PM -0700, Andi Kleen wrote:
> Dave Chinner <david@fromorbit.com> writes:
> >
> > First it would be useful to determine why the VM is reclaiming so
> > much memory. If it is somewhat predictable when the excessive
> > reclaim is going to happen, it might be worth capturing an event
> 
> Often it's to get pages of a higher order. Just tracing alloc_pages
> should tell you that.

Yes, the kmem/mm_page_alloc tracepoint gives us that. But in case
that is not the cause, grabbing all the trace points I suggested is
more likely to indicate where the problem is. I'd prefer to get more
data than needed the first time around than have to do multiple
round trips because a single trace point doesn't tell us the cause...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
