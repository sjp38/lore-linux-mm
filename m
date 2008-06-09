Date: Mon, 9 Jun 2008 01:32:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
Message-Id: <20080609013204.7c291b68.akpm@linux-foundation.org>
In-Reply-To: <20080605094826.128415000@nick.local0.net>
References: <20080605094300.295184000@nick.local0.net>
	<20080605094826.128415000@nick.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, 05 Jun 2008 19:43:07 +1000 npiggin@suse.de wrote:

> Implement lockless get_user_pages_fast for powerpc. Page table existence is
> guaranteed with RCU, and speculative page references are used to take a
> reference to the pages without having a prior existence guarantee on them.
> 

arch/powerpc/mm/gup.c: In function `get_user_pages_fast':
arch/powerpc/mm/gup.c:156: error: `SLICE_LOW_TOP' undeclared (first use in this function)
arch/powerpc/mm/gup.c:156: error: (Each undeclared identifier is reported only once
arch/powerpc/mm/gup.c:156: error: for each function it appears in.)
arch/powerpc/mm/gup.c:178: error: implicit declaration of function `get_slice_psize'
arch/powerpc/mm/gup.c:178: error: `mmu_huge_psize' undeclared (first use in this function)
arch/powerpc/mm/gup.c:182: error: implicit declaration of function `huge_pte_offset'
arch/powerpc/mm/gup.c:182: warning: assignment makes pointer from integer without a cast

with

http://userweb.kernel.org/~akpm/config-g5.txt

I don't immediately know why - adding asm/page.h to gup.c doesn't help.
I'm suspecting a recursive include problem somewhere.

I'll drop it, sorry - too much other stuff to fix over here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
