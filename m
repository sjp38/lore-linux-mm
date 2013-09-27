Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4E56B0081
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 10:35:07 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so2617041pbb.20
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 07:35:07 -0700 (PDT)
Message-ID: <1380292495.17366.106.camel@joe-AO722>
Subject: Re: [PATCH] checkpatch: Make the memory barrier test noisier
From: Joe Perches <joe@perches.com>
Date: Fri, 27 Sep 2013 07:34:55 -0700
In-Reply-To: <20130927142605.GC15690@laptop.programming.kicks-ass.net>
References: <1380228059.2170.10.camel@buesod1.americas.hpqcorp.net>
	 <1380229794.2602.36.camel@j-VirtualBox>
	 <1380231702.3467.85.camel@schen9-DESK>
	 <1380235333.3229.39.camel@j-VirtualBox>
	 <1380236265.3467.103.camel@schen9-DESK> <20130927060213.GA6673@gmail.com>
	 <20130927112323.GJ3657@laptop.programming.kicks-ass.net>
	 <1380289495.17366.91.camel@joe-AO722>
	 <20130927134802.GA15690@laptop.programming.kicks-ass.net>
	 <1380291257.17366.103.camel@joe-AO722>
	 <20130927142605.GC15690@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-09-27 at 16:26 +0200, Peter Zijlstra wrote:
> On Fri, Sep 27, 2013 at 07:14:17AM -0700, Joe Perches wrote:
> > Peter Zijlstra prefers that comments be required near uses
> > of memory barriers.
> > 
> > Change the message level for memory barrier uses from a
> > --strict test only to a normal WARN so it's always emitted.
> > 
> > This might produce false positives around insertions of
> > memory barriers when a comment is outside the patch context
> > block.
> 
> One would argue that in that case they're too far away in any case :-)
> 
> > And checkpatch is still stupid, it only looks for existence
> > of any comment, not at the comment content.
> 
> Could we try and alleviate this by giving a slightly more verbose
> warning?

> Maybe something like:
> 
>  memory barrier without comment; please refer to the pairing barrier and
>  describe the ordering requirements.

That would make it seem as if all barriers are SMP no?

Maybe just refer to Documentation/memory-barriers.txt
and/or say something like "please document appropriately"


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
