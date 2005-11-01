Date: Tue, 1 Nov 2005 14:56:51 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051101135651.GA8502@elte.hu>
References: <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0511011014060.14884@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

* Mel Gorman <mel@csn.ul.ie> wrote:

> The set of patches do fix a lot and make a strong start at addressing 
> the fragmentation problem, just not 100% of the way. [...]

do you have an expectation to be able to solve the 'fragmentation 
problem', all the time, in a 100% way, now or in the future?

> So, with this set of patches, how fragmented you get is dependant on 
> the workload and it may still break down and high order allocations 
> will fail. But the current situation is that it will defiantly break 
> down. The fact is that it has been reported that memory hotplug remove 
> works with these patches and doesn't without them. Granted, this is 
> just one feature on a high-end machine, but it is one solid operation 
> we can perform with the patches and cannot without them. [...]

can you always, under any circumstance hot unplug RAM with these patches 
applied? If not, do you have any expectation to reach 100%?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
