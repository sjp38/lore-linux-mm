Date: Fri, 19 Nov 2004 18:34:43 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page fault scalability patch V11 [0/7]: overview
Message-ID: <20041120023443.GD2714@holomorphy.com>
References: <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com> <419D581F.2080302@yahoo.com.au> <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com> <419D5E09.20805@yahoo.com.au> <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <20041120020401.GC2714@holomorphy.com> <419EA96E.9030206@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <419EA96E.9030206@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Split counters easily resolve the issues with both these approaches
>> (and apparently your co-workers are suggesting it too, and have
>> performance results backing it).

On Sat, Nov 20, 2004 at 01:18:22PM +1100, Nick Piggin wrote:
> Split counters still require atomic operations though. This is what
> Christoph's latest effort is directed at removing. And they'll still
> bounce cachelines around. (I assume we've reached the conclusion
> that per-cpu split counters per-mm won't fly?).

Split != per-cpu, though it may be. Counterexamples are
as simple as atomic_inc(&mm->rss[smp_processor_id()>>RSS_IDX_SHIFT]);
Furthermore, see Robin Holt's results regarding the performance of the
atomic operations and their relation to cacheline sharing.

And frankly, the argument that the space overhead of per-cpu counters
is problematic is not compelling. Even at 1024 cpus it's smaller than
an ia64 pagetable page, of which there are numerous instances attached
to each mm.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
