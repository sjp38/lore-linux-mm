Date: Sun, 23 Dec 2007 01:28:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-Id: <20071223012820.3a0e4db3.akpm@linux-foundation.org>
In-Reply-To: <20071223091405.GA15631@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de>
	<20071222005737.2675c33b.akpm@linux-foundation.org>
	<20071223055730.GA29288@wotan.suse.de>
	<20071222223234.7f0fbd8a.akpm@linux-foundation.org>
	<20071223071529.GC29288@wotan.suse.de>
	<20071222232932.590e2b6c.akpm@linux-foundation.org>
	<20071223091405.GA15631@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Sun, 23 Dec 2007 10:14:05 +0100 Nick Piggin <npiggin@suse.de> wrote:

>  config X86_PPRO_FENCE
> -	bool
> +	bool "PentiumPro memory ordering errata workaround"
>  	depends on M686 || M586MMX || M586TSC || M586 || M486 || M386 || MGEODEGX1
> -	default y
> +	default n
> +	help
> +	  Old PentiumPro multiprocessor systems had errata that could cause memory
> +	  operations to violate the x86 ordering standard in rare cases. Enabling this
> +	  option will attempt to work around some (but not all) occurances of
> +	  this problem, at the cost of much heavier spinlock and memory barrier
> +	  operations.
> +
> +	  If unsure, say n here. Even distro kernels should think twice before enabling
> +	  this: there are few systems, and an unlikely bug.
>  

I think if we're going to do this then we should add a runtime check for the
offending CPU then do panic("your kernel config ain't right").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
