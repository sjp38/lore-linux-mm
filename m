Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id B63D66B0038
	for <linux-mm@kvack.org>; Wed, 28 May 2014 19:17:19 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so11807238pbb.8
        for <linux-mm@kvack.org>; Wed, 28 May 2014 16:17:19 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id fl5si25427319pbb.220.2014.05.28.16.17.17
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 16:17:18 -0700 (PDT)
Date: Thu, 29 May 2014 09:17:08 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140528231708.GE6677@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <20140528101401.43853563@gandalf.local.home>
 <f00f9b56-704d-4d03-ad0e-ec3ba2d122fd@email.android.com>
 <20140528221118.GN8554@dastard>
 <5386664A.5060304@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5386664A.5060304@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>

On Wed, May 28, 2014 at 03:42:18PM -0700, H. Peter Anvin wrote:
> On 05/28/2014 03:11 PM, Dave Chinner wrote:
> > On Wed, May 28, 2014 at 07:23:23AM -0700, H. Peter Anvin wrote:
> >> We tried for 4K on x86-64, too, for b quite a while as I recall.
> >> The kernel stack is a one of the main costs for a thread.  I would
> >> like to decouple struct thread_info from the kernel stack (PJ
> >> Waskewicz was working on that before he left Intel) but that
> >> doesn't buy us all that much.
> >>
> >> 8K additional per thread is a huge hit.  XFS has indeed always
> >> been a canary, or troublespot, I suspect because it originally
> >> came from another kernel where this was not an optimization
> >> target.
> > 
> > <sigh>
> > 
> > Always blame XFS for stack usage problems.
> > 
> > Even when the reported problem is from IO to an ext4 filesystem.
> > 
> 
> You were the one calling it a canary.

That doesn't mean it's to blame. Don't shoot the messenger...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
