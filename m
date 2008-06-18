Date: Wed, 18 Jun 2008 14:12:21 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/1] MM: virtual address debug
Message-ID: <20080618121221.GB13714@elte.hu>
References: <1213271800-1556-1-git-send-email-jirislaby@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1213271800-1556-1-git-send-email-jirislaby@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, tglx@linutronix.de, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

* Jiri Slaby <jirislaby@gmail.com> wrote:

> Add some (configurable) expensive sanity checking to catch wrong address
> translations on x86.
> 
> - create linux/mmdebug.h file to be able include this file in
>   asm headers to not get unsolvable loops in header files
> - __phys_addr on x86_32 became a function in ioremap.c since
>   PAGE_OFFSET, is_vmalloc_addr and VMALLOC_* non-constasts are undefined
>   if declared in page_32.h
> - add __phys_addr_const for initializing doublefault_tss.__cr3

applied, thanks Jiri. I have created a new tip/x86/mm-debug topic for 
this because the patch touches mm/vmalloc.c and other MM bits.

Andrew, is that fine for you, can we push it into linux-next via 
auto-x86-next if it passes testing?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
