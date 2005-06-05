Date: Sun, 5 Jun 2005 12:45:56 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Message-ID: <20050605124556.A23271@flint.arm.linux.org.uk>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org> <20050602220213.D3468@flint.arm.linux.org.uk> <008201c569c3$61b30ab0$0f01a8c0@max>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <008201c569c3$61b30ab0$0f01a8c0@max>; from rpurdie@rpsys.net on Sun, Jun 05, 2005 at 12:39:36PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Purdie <rpurdie@rpsys.net>
Cc: Andrew Morton <akpm@osdl.org>, Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 05, 2005 at 12:39:36PM +0100, Richard Purdie wrote:
> 2.6.12-rc4-git1 contains the following patches:
> 
>     [PATCH] Fix root hole in pktcdvd
>     [PATCH] Fix root hole in raw device
>     [PATCH] fix Linux kernel ELF core dump privilege elevation
>     [PATCH] ARM: Fix build error
>     [PATCH] wireless: 3CRWE154G72 Kconfig help fix
>     [PATCH] Typo in tulip driver
>     [PATCH] {PATCH] Fix IBM EMAC driver ioctl bug
>     [PATCH] drivers/net/wireless enabled by wrong option
>     [PATCH] ARM: 2678/1: S3C2440 - cpu fixes, hdiv divisors and nand dev 
> name
>     [PATCH] ARM: 2676/1: S3C2440 - NAND register additions
>     [PATCH] ARM: 2677/1: S3C2440 - UPLL frequency doubled
>     [PATCH] ARM: 2680/1: refine TLS reg availability some more again
>     [PATCH] ARM: 2666/1: i.MX pwm controller defines
>     [PATCH] ARM: 2663/2: I can't type
>     [PATCH] ARM: Add V6 aliasing cache flush
>     [PATCH] ARM: Use top_pmd for V6 copy/clear user_page
>     [PATCH] ARM: Move copy/clear user_page locking into implementation

This one changes the way we do these operations on SA1100, but it got
tested prior to submission on the Assabet which didn't show anything
up.  However, if I had to pick one, it'd be this.

>     [PATCH] ARM: Add top_pmd, which points at the top-most page table
>     [PATCH] Serial: Add uart_insert_char()
>     [PATCH] ARM: Add inline functions to find the pmd from virtual address
>     [PATCH] MMC: wbsd update

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
