Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB8C6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 16:05:49 -0400 (EDT)
Date: Tue, 4 Aug 2009 22:35:26 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090804203526.GA8699@elte.hu>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <20090804195717.GA5998@elte.hu> <20090804131818.ee5d4696.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090804131818.ee5d4696.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl, fweisbec@gmail.com, rostedt@goodmis.org, mel@csn.ul.ie, lwoodman@redhat.com, riel@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 4 Aug 2009 21:57:17 +0200
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > Let me demonstrate these features in action (i've applied the 
> > patches for testing to -tip):
> 
> So?  The fact that certain things can be done doesn't mean that 
> there's a demand for them, nor that anyone will _use_ this stuff.

c'mon Andrew ...

Did you never want to see whether firefox is leaking [any sort of] 
memory, and if yes, on what callsites? Try something like on an 
already running firefox context:

  perf stat -e kmem:mm_page_alloc \
            -e kmem:mm_pagevec_free \
            -e kmem:mm_page_free_direct \
     -p $(pidof firefox-bin) sleep 10

... and "perf record" for the specific callsites.

this perf stuff is immensely flexible and a very unixish 
abstraction. The perf.data contains timestamped trace entries of 
page allocations and freeing done.

[...]
> It would be nice to at least partially remove the vmstat/meminfo 
> infrastructure but I don't think we can do that?

at least meminfo is an ABI for sure - vmstat too really.

But we can stop adding new fields into obsolete, inflexible and 
clearly deficient interfaces, and we can standardize new 
instrumentation to use modern instrumentation facilities - i.e. 
tracepoints and perfcounters.

I'm not saying to put a tracepoint on every second line of the 
kernel, but obviously Mel and Rik wanted this kind of info because 
they found it useful in practice.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
