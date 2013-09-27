Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A6B4C6B00B6
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 10:26:24 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so2880865pab.27
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 07:26:24 -0700 (PDT)
Date: Fri, 27 Sep 2013 16:26:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] checkpatch: Make the memory barrier test noisier
Message-ID: <20130927142605.GC15690@laptop.programming.kicks-ass.net>
References: <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net>
 <1380229794.2602.36.camel@j-VirtualBox>
 <1380231702.3467.85.camel@schen9-DESK>
 <1380235333.3229.39.camel@j-VirtualBox>
 <1380236265.3467.103.camel@schen9-DESK>
 <20130927060213.GA6673@gmail.com>
 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
 <1380289495.17366.91.camel@joe-AO722>
 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
 <1380291257.17366.103.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380291257.17366.103.camel@joe-AO722>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Sep 27, 2013 at 07:14:17AM -0700, Joe Perches wrote:
> Peter Zijlstra prefers that comments be required near uses
> of memory barriers.
> 
> Change the message level for memory barrier uses from a
> --strict test only to a normal WARN so it's always emitted.
> 
> This might produce false positives around insertions of
> memory barriers when a comment is outside the patch context
> block.

One would argue that in that case they're too far away in any case :-)

> And checkpatch is still stupid, it only looks for existence
> of any comment, not at the comment content.

Could we try and alleviate this by giving a slightly more verbose
warning?

Maybe something like:

 memory barrier without comment; please refer to the pairing barrier and
 describe the ordering requirements.

> Suggested-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Peter Zijlstra <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
