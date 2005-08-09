Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20050809080853.A25492@flint.arm.linux.org.uk>
References: <42F57FCA.9040805@yahoo.com.au>
	 <200508090710.00637.phillips@arcor.de>
	 <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au>
	 <20050809080853.A25492@flint.arm.linux.org.uk>
Content-Type: text/plain
Date: Tue, 09 Aug 2005 10:38:39 +0200
Message-Id: <1123576719.3839.13.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-08-09 at 08:08 +0100, Russell King wrote:
> On Tue, Aug 09, 2005 at 02:59:53PM +1000, Nick Piggin wrote:
> > That would work for swsusp, but there are other users that want to
> > know if a struct page is valid ram (eg. ioremap), so in that case
> > swsusp would not be able to mess with the flag.
> 
> The usage of "valid ram" here is confusing - that's not what PageReserved
> is all about.  It's about valid RAM which is managed by method other
> than the usual page counting.  Non-reserved RAM is also valid RAM, but
> is managed by the kernel in the usual way.
> 
> The former is available for remap_pfn_range and ioremap, the latter is
> not.
> 
> On the other hand, the validity of an apparant RAM address can only be
> tested using its pfn with pfn_valid().
> 
> Can we straighten out the terminology so it's less confusing please?
> 

and..... can we make a general page_is_ram() function that does what it
says? on x86 it can go via the e820 table, other architectures can do
whatever they need....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
