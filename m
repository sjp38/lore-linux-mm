Message-ID: <418CBED7.6050609@yahoo.com.au>
Date: Sat, 06 Nov 2004 23:08:55 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
References: <418AE0F0.5050908@yahoo.com.au> <418AE9BB.1000602@yahoo.com.au> <1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com> <418CA535.1030703@yahoo.com.au> <20041106103103.GC2890@holomorphy.com> <418CAA44.3090007@yahoo.com.au> <20041106105314.GD2890@holomorphy.com> <418CB06F.1080405@yahoo.com.au> <20041106120624.GE2890@holomorphy.com>
In-Reply-To: <20041106120624.GE2890@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> William Lee Irwin III wrote:
> 
>>>Per-cpu magazines look okay to me. Failing that, per groups of cpus.
>>>Failing that, hash. And so on. This is all boilerplate material. Split
>>>counters are not rocket science. No calc of variations, no time-
>>>dependent densities or moments of inertia, etc.
> 
> 
> On Sat, Nov 06, 2004 at 10:07:27PM +1100, Nick Piggin wrote:
> 
>>The problem being that a page can be allocated on one CPU and freed
>>on another.
>>Well that can actually be workable... but its ugly, and rules out a
>>perfectly scalable, mmap_sem'less page fault (looking far into the
>>future here :P).
> 
> 
> There is no conflict. The sums are invariant under overflows.
> 

If they're not racy.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
