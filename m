Date: Tue, 1 Nov 2005 16:01:42 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051101150142.GA10636@elte.hu>
References: <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130856555.14475.77.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

* Dave Hansen <haveblue@us.ibm.com> wrote:

> > then we need to see that 100% solution first - at least in terms of 
> > conceptual steps.
> 
> I don't think saying "truly 100%" really even makes sense.  There will 
> always be restrictions of some kind.  For instance, with a 10MB kernel 
> image, should you be able to shrink the memory in the system below 
> 10MB? ;)

think of it in terms of filesystem shrinking: yes, obviously you cannot 
shrink to below the allocated size, but no user expects to be able to do 
it. But users would not accept filesystem shrinking failing for certain 
file layouts. In that case we are better off with no ability to shrink: 
it makes it clear that we have not solved the problem, yet.

so it's all about expectations: _could_ you reasonably remove a piece of 
RAM? Customer will say: "I have stopped all nonessential services, and 
free RAM is at 90%, still I cannot remove that piece of faulty RAM, fix 
the kernel!". No reasonable customer will say: "True, I have all RAM 
used up in mlock()ed sections, but i want to remove some RAM 
nevertheless".

> There is also no precedent in existing UNIXes for a 100% solution.

does this have any relevance to the point, other than to prove that it's 
a hard problem that we should not pretend to be able to solve, without 
seeing a clear path towards a solution?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
