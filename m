Date: Mon, 19 Apr 2004 00:34:28 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040419003428.A4676@flint.arm.linux.org.uk>
References: <20040418205513.A27725@flint.arm.linux.org.uk> <Pine.LNX.4.44.0404190007440.21497-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0404190007440.21497-100000@localhost.localdomain>; from hugh@veritas.com on Mon, Apr 19, 2004 at 12:14:01AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 19, 2004 at 12:14:01AM +0100, Hugh Dickins wrote:
> I think you're choosing the wrong moment to get into all of this.
> 
> Assuming one or another form of object-based rmap really does go in,
> pte_addr_t, ptep_to_mm, include/asm*/rmap.h all disappear.  The
> patch for that went to Andrew on Friday, you were on the CC list.
> 
> Revisit in a couple of weeks?

Nevertheless, getting rid of all those needless asm/pgalloc.h includes
is something worth doing anyway.  This isn't the first time not being
able to get at mm_struct / vma_area_struct in asm/pgtable.h has been
a problem.

So I think its worth sorting this out anyway, independent of the
rmap changes.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
