Date: Sat, 17 Apr 2004 13:43:02 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040417204302.GR743@holomorphy.com>
References: <20040417211506.C21974@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417211506.C21974@flint.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2004 at 09:15:06PM +0100, Russell King wrote:
> This in turn means that we need to replace ptep_test_and_clear_young()
> with ptep_clear_flush_young(), which in turn means we need the VMA and
> address.  However, this implies introducing more code into
> page_referenced().
> Comments?

The address and mm should already be recoverable via the pte page
tagging technique. The vma is recoverable from that, albeit at some
cost (mm->page_table_lock acquisition + find_vma() call). OTOH unless
kswapd's going wild it should largely count as a slow path anyway.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
