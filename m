Message-ID: <42F877FF.9000803@yahoo.com.au>
Date: Tue, 09 Aug 2005 19:31:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
References: <42F57FCA.9040805@yahoo.com.au>	 <200508090710.00637.phillips@arcor.de>	 <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au>	 <20050809080853.A25492@flint.arm.linux.org.uk> <1123576719.3839.13.camel@laptopd505.fenrus.org>
In-Reply-To: <1123576719.3839.13.camel@laptopd505.fenrus.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Arjan van de Ven wrote:
> On Tue, 2005-08-09 at 08:08 +0100, Russell King wrote:

>>Can we straighten out the terminology so it's less confusing please?
>>
> 
> 
> and..... can we make a general page_is_ram() function that does what it
> says? on x86 it can go via the e820 table, other architectures can do
> whatever they need....
> 

That would be very helpful. That should cover the remaining (ab)users
of PageReserved.

It would probably be fastest to implement this with a page flag,
however if swsusp and ioremap are the only users then it shouldn't
be a problem to go through slower lookups (and this would remove the
need for the PageValidRAM flag that I had worried about earlier).

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
