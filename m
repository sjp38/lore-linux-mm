Date: Sun, 18 Apr 2004 02:39:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418093949.GY743@holomorphy.com>
References: <20040417211506.C21974@flint.arm.linux.org.uk> <20040417204302.GR743@holomorphy.com> <20040418103616.B5745@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040418103616.B5745@flint.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2004 at 01:43:02PM -0700, William Lee Irwin III wrote:
>> The address and mm should already be recoverable via the pte page
>> tagging technique. The vma is recoverable from that, albeit at some
>> cost (mm->page_table_lock acquisition + find_vma() call). OTOH unless
>> kswapd's going wild it should largely count as a slow path anyway.

On Sun, Apr 18, 2004 at 10:36:16AM +0100, Russell King wrote:
> Actually, we don't actually need the VMA - if you look at flush_tlb_page()
> in include/asm-arm/tlbflush.h, we only really need the MM.  Therefore,
> it's pointless digging up the VMA.  (I did think that we didn't flush
> the I-TLB if VM_EXEC wasn't set, but I think that was a previous
> incarnation.)

This sounds like when hugh's stuff to prep for either his or andrea's
try_to_unmap() reimplementation goes in, something akin to current ppc64
may be needed for ARM. That should preserve the mm/address tagging by
shoving the pte page tagging into arch code.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
