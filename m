Date: Sat, 5 Jul 2008 13:10:24 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Deinline a few functions in mmap.c
Message-ID: <20080705171024.GA4723@infradead.org>
References: <200807051837.30219.vda.linux@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200807051837.30219.vda.linux@googlemail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 05, 2008 at 06:37:30PM +0200, Denys Vlasenko wrote:
>  #if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
>  /*
>   * PA-RISC uses this for its stack; IA64 for its Register Backing Store.
>   * vma is the last one with address > vma->vm_end.  Have to extend vma.
>   */
>  #ifndef CONFIG_IA64
> -static inline
> +static
>  #endif

Unrelated note, but I think this ifdef should go.  We've always prefered
slightly less possible optimizations over horribly ugly ifdefs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
