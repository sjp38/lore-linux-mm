Date: Fri, 2 Mar 2007 19:55:37 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070303035537.GD23573@holomorphy.com>
References: <45E86BA0.50508@redhat.com> <20070302211207.GJ10643@holomorphy.com> <45E894D7.2040309@redhat.com> <20070302135243.ada51084.akpm@linux-foundation.org> <45E89F1E.8020803@redhat.com> <20070302142256.0127f5ac.akpm@linux-foundation.org> <45E8A677.7000205@redhat.com> <20070302145906.653d3b82.akpm@linux-foundation.org> <20070303014004.GC23573@holomorphy.com> <20070302175856.bb9de72d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070302175856.bb9de72d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Bill Irwin <bill.irwin@oracle.com>, Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007 17:40:04 -0800 William Lee Irwin III <wli@holomorphy.com> wrote:
>> My gut feeling is to agree, but I get nagging doubts when I try to
>> think of how to boil things like [major benchmarks whose names are
>> trademarked/copyrighted/etc. censored] down to simple testcases. Some
>> other things are obvious but require vast resources, like zillions of
>> disks fooling throttling/etc. heuristics of ancient downrev kernels.

On Fri, Mar 02, 2007 at 05:58:56PM -0800, Andrew Morton wrote:
> noooooooooo.  You're approaching it from the wrong direction.
> Step 1 is to understand what is happening on the affected production
> system.  Completely.  Once that is fully understood then it is a relatively
> simple matter to concoct a test case which triggers the same failure mode.
> It is very hard to go the other way: to poke around with various stress
> tests which you think are doing something similar to what you think the
> application does in the hope that similar symptoms will trigger so you can
> then work out what the kernel is doing.  yuk.

Yeah, it's really great when it's possible to get debug info out of
people e.g. they're willing to boot into a kernel instrumented with
the appropriate printk's/etc. Most of the time it's all guesswork.
People who post to lkml are much better about all this on average.

I never truly understood the point of kprobes/jprobes/dprobes (or
whatever the probing letter is), crash dumps, and so on until I ran
into this, not that I use personally them (though I may yet start).
Most of the time I just read the code instead and smoke out what
could be going on by something like the process of devising
counterexamples. For instance, I told that colouroff patch guy about
the possibility of getting the wrong page for the start of the buffer
from virt_to_page() on a cache colored buffer pointer (clearly
cache->gfporder >= 4 in such a case). Deriving the head page without
__GFP_COMP might be considered to be ugly-looking, though.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
