Date: Sun, 25 Mar 2001 17:33:44 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [patch] pae-2.4.3-A4
Message-ID: <20010325173344.B30655@flint.arm.linux.org.uk>
References: <Pine.LNX.4.31.0103191839510.1003-100000@penguin.transmeta.com> <Pine.LNX.4.30.0103251643070.6469-200000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.30.0103251643070.6469-200000@elte.hu>; from mingo@elte.hu on Sun, Mar 25, 2001 at 04:53:37PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Linux Kernel List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 25, 2001 at 04:53:37PM +0200, Ingo Molnar wrote:
> one nontrivial issue was that on PAE the pgd has to be installed with
> 'present' pgd entries, due to a CPU erratum. This means that the
> pgd_present() code in mm/memory.c, while correct theoretically, doesnt
> work with PAE. An equivalent solution is to use !pgd_none(), which also
> works with the PAE workaround.

Certainly that's the way the original *_alloc routines used to work.
In fact, ARM never had need to implement the pmd_present() macros, since
they were never referenced - only the pmd_none() macros were.

However, I'm currently struggling with this change on ARM - so far after
a number of hours trying to kick something into shape, I've not managed
to even get to the stange where I get a kernel image to link, let alone
the compilation to finish.

One of my many dilemas at the moment is how to allocate the page 0 PMD
in pgd_alloc(), where we don't have a mm_struct to do the locking against.

--
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
