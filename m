Date: Mon, 7 Jan 2008 10:30:29 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
Message-ID: <20080107103028.GA9325@flint.arm.linux.org.uk>
References: <20071221104701.GE28484@wotan.suse.de> <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com> <20080107044355.GA11222@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080107044355.GA11222@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 05:43:55AM +0100, Nick Piggin wrote:
> We initially wanted to do the whole vm_normal_page thing this way, with
> another pte bit, but we thought there were one or two archs with no spare
> bits. BTW. I also need this bit in order to implement my lockless
> get_user_pages, so I do hope to get it in. I'd like to know what
> architectures cannot spare a software bit in their pte_present ptes...

ARM is going to have to use the three remaining bits we have in the PTE
to store the memory type to resolve bugs on later platforms.  Once they're
used, ARM will no longer have any room for any further PTE expansion.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
