Date: Sat, 20 Jul 2002 14:15:39 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] generalized spin_lock_bit
Message-ID: <20020720211539.GG1096@holomorphy.com>
References: <1027196511.1555.767.camel@sinai> <Pine.LNX.4.44.0207201335560.1492-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0207201335560.1492-100000@home.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Robert Love <rml@tech9.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On 20 Jul 2002, Robert Love wrote:
>> The attached patch implements bit-sized spinlocks via the following
>> interfaces:

On Sat, Jul 20, 2002 at 01:40:22PM -0700, Linus Torvalds wrote:
> In particular, with the current pte_chain_lock() interface, it will be
> _trivial_ to turn that bit in page->flags to be instead a hash based on
> the page address into an array of spinlocks. Which is a lot more portable
> than the current code.
> (The current code works, but look at what it generates on old sparcs, for
> example).

I was hoping to devolve the issue of the implementation of it to arch
maintainers by asking for this. I was vaguely aware that the atomic bit
operations are implemented via hashed spinlocks on PA-RISC and some
others, so by asking for the right primitives to come back up from arch
code I hoped those who spin elsewhere might take advantage of their
window of exclusive ownership.

Would saying "Here is an address, please lock it, and if you must flip
a bit, use this bit" suffice? I thought it might give arch code enough
room to wiggle, but is it enough?


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
