Date: Tue, 9 Aug 2005 13:51:55 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
In-Reply-To: <20050809204100.B29945@flint.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.58.0508091351170.3258@g5.osdl.org>
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de>
 <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au>
 <20050809080853.A25492@flint.arm.linux.org.uk> <523240000.1123598289@[10.10.2.4]>
 <20050809204100.B29945@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Nick Piggin <nickpiggin@yahoo.com.au>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>


On Tue, 9 Aug 2005, Russell King wrote:

> On Tue, Aug 09, 2005 at 07:38:52AM -0700, Martin J. Bligh wrote:
> > pfn_valid() doesn't tell you it's RAM or not - it tells you whether you
> > have a backing struct page for that address. Could be an IO mapped device,
> > a small memory hole, whatever.
> 
> The only things which have a struct page is RAM.  Nothing else does.

That's not true.

We have "struct page" show up for the ISA legacy MMIO region too, for 
example.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
