Date: Tue, 8 Jan 2008 14:08:21 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
Message-ID: <20080108140821.GA8146@flint.arm.linux.org.uk>
References: <20071221104701.GE28484@wotan.suse.de> <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com> <20080107044355.GA11222@wotan.suse.de> <20080107103028.GA9325@flint.arm.linux.org.uk> <6934efce0801071049u546005e7t7da4311cc0611ccd@mail.gmail.com> <20080107194543.GA2788@flint.arm.linux.org.uk> <1199787075.17809.10.camel@pc1117.cambridge.arm.com> <20080108105227.GA10546@flint.arm.linux.org.uk> <1199800456.17809.72.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1199800456.17809.72.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Jared Hulbert <jaredeh@gmail.com>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 08, 2008 at 01:54:15PM +0000, Catalin Marinas wrote:
> On Tue, 2008-01-08 at 10:52 +0000, Russell King wrote:
> > It's unclear at present what circumstances you'd use each of the two
> > Xscale3 work-around bit combinations - or indeed whether there's a
> > printing error in the documentation concerning TEXCB=00101.
> 
> As I said, I don't know the details of this bug and can't comment.

As I said I don't think there's anything further that can be usefully
added to this discussion until we're further down the road with this.

Even though you don't know the details of the bug report, I've mentioned
as much as I know about it at present - and that includes with access to
Marvells spec update document.  When I'm further down the line with PXA3
work maybe I'll know more, but my priority at the moment on PXA3 is
suspend/resume support.

> I haven't run any benchmarks and I can't say how big the impact is but,
> based on some past discussions, 3-4 more cycles in set_pte might go
> unnoticed because of other, bigger overheads.

Except when you're clearing out page tables - for instance when a
thread exits.  It's very noticable and shows up rather well in
fork+exit tests - even shell scripts.

This was certainly the case with 2.2 kernels.  Whether 2.6 kernels
are soo heavy weight that it's been swapped into non-existence I
don't know.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
