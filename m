From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: mlockall and mmap of IO devices don't mix
Date: Sat, 4 Oct 2003 16:19:49 +0200
References: <CFYv.787.23@gated-at.bofh.it> <200310041202.08742.ioe-lkml@rameria.de> <20031004111336.C18928@flint.arm.linux.org.uk>
In-Reply-To: <20031004111336.C18928@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200310041619.49392.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, Joe Korty <joe.korty@ccur.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi there,

CC'ed linux-mm and Andrew Morton for expertise.

On Saturday 04 October 2003 12:13, Russell King wrote:
> It has to be correct.  We do the following in a hell of a lot of places:
>
> 	pfn = pte_pfn(pte);
> 	if (pfn_valid(pfn)) {
> 		struct page *page = pfn_to_page(pfn);
> 		/* do something with page */
> 	}
>
> basically this type of thing happens in any of the PTE manipulation
> functions (eg, copy_page_range, zap_pte_range, etc.)

These functions are called always with pages, where we know, that this
is RAM, AFICS. Since sometimes other things are encoded in the PTE, whe
check this via pfn_valid().

If I'm wrong about this the gurus from LINUX-MM should complain loudly.

> If pfn_valid is returning false positives, and you happen to mmap() an
> area which gives false positives from a user space application, your
> kernel will either oops or will corrupt RAM when that application exits.
>
> I believe the comment in mmzone.h therefore is an opinion, and indicates
> a concern for performance rather than correctness and stability.

I hope you are wrong about this, but I'm not totally sure. So I included
the linux-mm mailing list and Andrew Morton for expert advice.

Regards

Ingo Oeser


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
