Date: Sun, 18 Apr 2004 08:12:59 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418151259.GZ743@holomorphy.com>
References: <20040417211506.C21974@flint.arm.linux.org.uk> <20040417204302.GR743@holomorphy.com> <20040418103616.B5745@flint.arm.linux.org.uk> <20040418114211.A9952@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040418114211.A9952@flint.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 11:42:11AM +0100, Russell King wrote:
> Ok, so linux/mm.h includes asm/pgtable.h, which in turn includes
> asm-generic/pgtable.h.  I need to get at the mm and address in my
> implementation of ptep_test_and_clear_young() - and the functions
> are defined in asm-generic/rmap.h.  This includes linux/mm.h, so
> I can't include it in asm/pgtable.h. Moreover, mm_struct hasn't
> been declared yet.
> Converting ptep_test_and_clear_young() to be a macro doesn't look
> sane either, not without creating some rather disgusting code.
> So, how do I get at the mm_struct and address in asm/pgtable.h ?
> Maybe we need to split out the pte manipulation into asm/pte.h rather
> than overloading pgtable.h with it?

I think the usual answer is "lots of giant macros." =(


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
