Subject: Re: page table lock patch V15 [0/7]: overview II
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <m14qhkr4sd.fsf_-_@muc.de>
References: <41E5AFE6.6000509@yahoo.com.au>
	 <20050112153033.6e2e4c6e.akpm@osdl.org> <41E5B7AD.40304@yahoo.com.au>
	 <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com>
	 <41E5BC60.3090309@yahoo.com.au>
	 <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
	 <20050113031807.GA97340@muc.de>
	 <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
	 <20050113180205.GA17600@muc.de>
	 <Pine.LNX.4.58.0501131701150.21743@schroedinger.engr.sgi.com>
	 <20050114043944.GB41559@muc.de>  <m14qhkr4sd.fsf_-_@muc.de>
Content-Type: text/plain
Date: Fri, 14 Jan 2005 15:59:02 +1100
Message-Id: <1105678742.5402.109.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: clameter@sgi.com, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-01-14 at 05:52 +0100, Andi Kleen wrote:
> Andi Kleen <ak@muc.de> writes:
> > As you can see cmpxchg is slightly faster for the cache hot case,
> > but incredibly slow for cache cold (probably because it does something
> > nasty on the bus). This is pretty consistent to Intel and AMD CPUs.
> > Given that page tables are likely more often cache cold than hot 
> > I would use the lazy variant. 
> 
> Sorry, my benchmark program actually had a bug (first loop included
> page faults). Here are updated numbers. They are somewhat different:
> 
> Athlon 64:
> readpte hot 25
> readpte cold 171
> readpte_cmp hot 18
> readpte_cmp cold 162
> 
> Nocona:
> readpte hot 118
> readpte cold 443
> readpte_cmp hot 22
> readpte_cmp cold 224
> 
> The difference is much smaller here.  Assuming cache cold cmpxchg8b is
> better, at least on the Intel CPUs which have a slow rmb().
> 

I have a question for the x86 gurus. We're currently using the lock
prefix for set_64bit. This will lock the bus for the RMW cycle, but
is it a prerequisite for the atomic 64-bit store? Even on UP?



Find local movie times and trailers on Yahoo! Movies.
http://au.movies.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
