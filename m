Received: from [192.168.184.31] ([192.168.184.31]) (1591 bytes) by
    megami.veritas.com via sendmail with P:esmtp/R:smart_host/T:smtp
    (sender: <hugh@veritas.com>) id <m1BFLUA-0000iDC@megami.veritas.com> for
    <linux-mm@kvack.org>; Sun, 18 Apr 2004 16:14:02 -0700 (PDT)
    (Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Mon, 19 Apr 2004 00:14:01 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
In-Reply-To: <20040418205513.A27725@flint.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.44.0404190007440.21497-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 18 Apr 2004, Russell King wrote:

> On Sun, Apr 18, 2004 at 01:42:28PM +0100, Russell King wrote:
> > Basically, to be able to use either ptep_to_mm() or ptep_to_address()
> > in asm/pgtable.h, you need to:
> > 
> > 1. remove linux/mm.h from asm-generic/rmap.h
> > 2. somehow work around linux/highmem.h which includes linux/mm.h so
> >    asm-generic/rmap.h can have a definition of kmap_atomic_to_page()
> > 3. remove asm/pgtable.h from linux/mm.h and linux/page-flags.h
> > 
> > I've managed to get so far with that, but the real killer seems to
> > be (2).
> 
> Ok, I've found a solution.

I think you're choosing the wrong moment to get into all of this.

Assuming one or another form of object-based rmap really does go in,
pte_addr_t, ptep_to_mm, include/asm*/rmap.h all disappear.  The
patch for that went to Andrew on Friday, you were on the CC list.

Revisit in a couple of weeks?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
