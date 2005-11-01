Date: Tue, 1 Nov 2005 15:29:59 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051101142959.GA9272@elte.hu>
References: <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130854224.14475.60.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

* Dave Hansen <haveblue@us.ibm.com> wrote:

> > can you always, under any circumstance hot unplug RAM with these patches 
> > applied? If not, do you have any expectation to reach 100%?
> 
> With these patches, no.  There are currently some very nice, 
> pathological workloads which will still cause fragmentation.  But, in 
> the interest of incremental feature introduction, I think they're a 
> fine first step.  We can effectively reach toward a more comprehensive 
> solution on top of these patches.
> 
> Reaching truly 100% will require some other changes such as being able 
> to virtually remap things like kernel text.

then we need to see that 100% solution first - at least in terms of 
conceptual steps. Not being able to hot-unplug RAM in a 100% way wont 
satisfy customers. Whatever solution we choose, it must work 100%. Just 
to give a comparison: would you be content with your computer failing to 
start up apps 1 time out of 100, saying that 99% is good enough? Or 
would you call it what it is: buggy and unreliable?

to stress it: hot unplug is a _feature_ that must work 100%, _not_ some 
optimization where 99% is good enough. This is a feature that people 
will be depending on if we promise it, and 1% failure rate is not 
acceptable. Your 'pathological workload' might be customer X's daily 
workload. Unless there is a clear definition of what is possible and 
what is not (which definition can be relied upon by users), having a 99% 
solution is much worse than the current 0% solution!

worse than that, this is a known _hard_ problem to solve in a 100% way, 
and saying 'this patch is a good first step' just lures us (and 
customers) into believing that we are only 1% away from the desired 100% 
solution, while nothing could be further from the truth. They will 
demand the remaining 1%, but can we offer it? Unless you can provide a 
clear, accepted-upon path towards the 100% solution, we have nothing 
right now.

I have no problems with using higher-order pages for performance 
purposes [*], as long as 'failed' allocation (and freeing) actions are 
user-invisible. But the moment you make it user-visible, it _must_ work 
in a deterministic way!

	Ingo

[*] in which case any slowdown in the page allocator must be offset by
    the gains.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
