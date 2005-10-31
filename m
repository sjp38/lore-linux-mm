Message-ID: <4366A8D1.7020507@yahoo.com.au>
Date: Tue, 01 Nov 2005 10:29:21 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au> <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]>
In-Reply-To: <27700000.1130769270@[10.10.2.4]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

>>We think that Mel's patches will allow us to reintroduce Rohit's
>>optimisation.
> 
> 
> ... frankly, it happens without Rohit's patch as well (under more stress).
> If we want a OS that is robust, and supports higher order allocations,
> we need to start caring about fragmentations. Not just for large pages,
> and hotplug, but also for more common things like jumbo GigE frames,
> CIFS, various device drivers, kernel stacks > 4K etc. 
> 

But it doesn't seem to be a great problem right now, apart from hotplug
and hugepages. Some jumbo GigE drivers use higher order allocations, but
I think there are moves to get away from that (e1000, for example).

> To me, the question is "do we support higher order allocations, or not?".
> Pretending we do, making a half-assed job of it, and then it not working
> well under pressure is not helping anyone. I'm told, for instance, that
> AMD64 requires > 4K stacks - that's pretty fundamental, as just one 

And i386 had required 8K stacks for a long long time too.

> instance. I'd rather make Linux pretty bulletproof - the added feature
> stuff is just a bonus that comes for free with that.
> 

But this doesn't exactly make Linux bulletproof, AFAIKS it doesn't work
well on small memory systems, and it can still get fragmented and not work.
IMO in order to make Linux bulletproof, just have fallbacks for anything
greater than about order 2 allocations.

 From what I have seen, by far our biggest problems in the mm are due to
page reclaim, and these patches will make our reclaim behaviour more
complex I think.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
