Date: Fri, 19 Nov 2004 19:43:49 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page fault scalability patch V11 [0/7]: overview
Message-ID: <20041120034349.GG2714@holomorphy.com>
References: <419D5E09.20805@yahoo.com.au> <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <20041120020401.GC2714@holomorphy.com> <419EA96E.9030206@yahoo.com.au> <20041120023443.GD2714@holomorphy.com> <419EAEA8.2060204@yahoo.com.au> <20041120030425.GF2714@holomorphy.com> <419EB699.4050204@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <419EB699.4050204@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Irrelevant. Unshare cachelines with hot mm-global ones, and the
>> "problem" goes away.

On Sat, Nov 20, 2004 at 02:14:33PM +1100, Nick Piggin wrote:
> That's the idea.


William Lee Irwin III wrote:
>> This stuff is going on and on about some purist "no atomic operations
>> anywhere" weirdness even though killing the last atomic operation
>> creates problems and doesn't improve performance.

On Sat, Nov 20, 2004 at 02:14:33PM +1100, Nick Piggin wrote:
> Huh? How is not wanting to impact single threaded performance being
> "purist weirdness"? Practical, I'd call it.

Empirically demonstrate the impact on single-threaded performance.


On Sat, Nov 20, 2004 at 01:40:40PM +1100, Nick Piggin wrote:
>> Why the Hell would you bother giving each cpu a separate cacheline?
>> The odds of bouncing significantly merely amongst the counters are not
>> particularly high.

On Sat, Nov 20, 2004 at 02:14:33PM +1100, Nick Piggin wrote:
> Hmm yeah I guess wouldn't put them all on different cachelines.
> As you can see though, Christoph ran into a wall at 8 CPUs, so
> having them densly packed still might not be enough.

Please be more specific about the result, and cite the Message-Id.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
