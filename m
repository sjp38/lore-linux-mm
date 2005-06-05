Message-ID: <008201c569c3$61b30ab0$0f01a8c0@max>
From: "Richard Purdie" <rpurdie@rpsys.net>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org> <20050602220213.D3468@flint.arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Date: Sun, 5 Jun 2005 12:39:36 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>, Andrew Morton <akpm@osdl.org>
Cc: Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King:
> I'm not sure what happened with this, but there's someone reporting that
> -rc5-mm1 doesn't work.  Unfortunately, there's not a lot to go on:
>
> http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2005-May/029188.html
>
> Could be unrelated for all I know.

I've been going around in circles chasing the previously mentioned memory 
corruption type bug. It causes random(ish) segfaults as the system boots. 
Sometimes they're serious and stop the system dead sometimes they're not. I 
have also see alignment errors and floating point errors.

I've traced this back to 2.6.12-rc4-git1. 2.6.12-rc4 works fine. The -git1 
release has these random segfaults. I'd previously said 2.6.12-rc5 was ok - 
it isn't, it was just more subtlety broken :-(. This may or may not by why 
2.6.12-rc5-mm1 stops dead and certainly looks similar to the random 
segfaults under 2.6.12-rc5-mm2.

2.6.12-rc4-git1 contains the following patches:

    [PATCH] Fix root hole in pktcdvd
    [PATCH] Fix root hole in raw device
    [PATCH] fix Linux kernel ELF core dump privilege elevation
    [PATCH] ARM: Fix build error
    [PATCH] wireless: 3CRWE154G72 Kconfig help fix
    [PATCH] Typo in tulip driver
    [PATCH] {PATCH] Fix IBM EMAC driver ioctl bug
    [PATCH] drivers/net/wireless enabled by wrong option
    [PATCH] ARM: 2678/1: S3C2440 - cpu fixes, hdiv divisors and nand dev 
name
    [PATCH] ARM: 2676/1: S3C2440 - NAND register additions
    [PATCH] ARM: 2677/1: S3C2440 - UPLL frequency doubled
    [PATCH] ARM: 2680/1: refine TLS reg availability some more again
    [PATCH] ARM: 2666/1: i.MX pwm controller defines
    [PATCH] ARM: 2663/2: I can't type
    [PATCH] ARM: Add V6 aliasing cache flush
    [PATCH] ARM: Use top_pmd for V6 copy/clear user_page
    [PATCH] ARM: Move copy/clear user_page locking into implementation
    [PATCH] ARM: Add top_pmd, which points at the top-most page table
    [PATCH] Serial: Add uart_insert_char()
    [PATCH] ARM: Add inline functions to find the pmd from virtual address
    [PATCH] MMC: wbsd update

There are some farily serious mm changes on arm there and I suspect one of 
them is at fault.

Russell: Any idea which one it might be offhand?

Richard 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
