Message-ID: <419EB699.4050204@yahoo.com.au>
Date: Sat, 20 Nov 2004 14:14:33 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V11 [0/7]: overview
References: <419D581F.2080302@yahoo.com.au> <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com> <419D5E09.20805@yahoo.com.au> <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <20041120020401.GC2714@holomorphy.com> <419EA96E.9030206@yahoo.com.au> <20041120023443.GD2714@holomorphy.com> <419EAEA8.2060204@yahoo.com.au> <20041120030425.GF2714@holomorphy.com>
In-Reply-To: <20041120030425.GF2714@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> William Lee Irwin III wrote:
> 
>>>Furthermore, see Robin Holt's results regarding the performance of the
>>>atomic operations and their relation to cacheline sharing.
> 
> 
> On Sat, Nov 20, 2004 at 01:40:40PM +1100, Nick Piggin wrote:
> 
>>Well yeah, but a. their patch isn't in 2.6 (or 2.4), and b. anon_rss
> 
> 
> Irrelevant. Unshare cachelines with hot mm-global ones, and the
> "problem" goes away.
> 

That's the idea.

> This stuff is going on and on about some purist "no atomic operations
> anywhere" weirdness even though killing the last atomic operation
> creates problems and doesn't improve performance.
> 

Huh? How is not wanting to impact single threaded performance being
"purist weirdness"? Practical, I'd call it.

> 
> On Sat, Nov 20, 2004 at 01:40:40PM +1100, Nick Piggin wrote:
> 
>>means another atomic op. While this doesn't immediately make it a
>>showstopper, it is gradually slowing down the single threaded page
>>fault path too, which is bad.
> 
> 
> William Lee Irwin III wrote:
> 
>>>And frankly, the argument that the space overhead of per-cpu counters
>>>is problematic is not compelling. Even at 1024 cpus it's smaller than
>>>an ia64 pagetable page, of which there are numerous instances attached
>>>to each mm.
> 
> 
> On Sat, Nov 20, 2004 at 01:40:40PM +1100, Nick Piggin wrote:
> 
>>1024 CPUs * 64 byte cachelines == 64K, no? Well I'm sure they probably
>>don't even care about 64K on their large machines, but...
>>On i386 this would be maybe 32 * 128 byte == 4K per task for distro
>>kernels. Not so good.
> 
> 
> Why the Hell would you bother giving each cpu a separate cacheline?
> The odds of bouncing significantly merely amongst the counters are not
> particularly high.
> 

Hmm yeah I guess wouldn't put them all on different cachelines.
As you can see though, Christoph ran into a wall at 8 CPUs, so
having them densly packed still might not be enough.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
