Date: Tue, 7 Aug 2007 21:03:57 +0200
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [patch 3/3] mm: variable length argument support
Message-ID: <20070807190357.GA31139@aepfle.de>
References: <20070613100334.635756997@chello.nl> <20070613100835.014096712@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20070613100835.014096712@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, Peter Zijlstra wrote:

> From: Ollie Wild <aaw@google.com>
> 
> Remove the arg+env limit of MAX_ARG_PAGES by copying the strings directly
> from the old mm into the new mm.

> +++ linux-2.6-2/include/linux/binfmts.h	2007-06-13 11:52:46.000000000 +0200
> @@ -6,11 +6,13 @@
>  struct pt_regs;
>  
>  /*
> - * MAX_ARG_PAGES defines the number of pages allocated for arguments
> - * and envelope for the new program. 32 should suffice, this gives
> - * a maximum env+arg of 128kB w/4KB pages!
> + * These are the maximum length and maximum number of strings passed to the
> + * execve() system call.  MAX_ARG_STRLEN is essentially random but serves to
> + * prevent the kernel from being unduly impacted by misaddressed pointers.
> + * MAX_ARG_STRINGS is chosen to fit in a signed 32-bit integer.
>   */
> -#define MAX_ARG_PAGES 32
> +#define MAX_ARG_STRLEN (PAGE_SIZE * 32)
> +#define MAX_ARG_STRINGS 0x7FFFFFFF

This adds a new usage of PAGE_SIZE to an exported header.
How can this be fixed for 2.6.23?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
