Date: Wed, 27 Apr 2005 16:50:43 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 4/4] VM: automatic reclaim through mempolicy
Message-Id: <20050427165043.7ff66a19.akpm@osdl.org>
In-Reply-To: <20050427151010.GV8018@localhost>
References: <20050427145734.GL8018@localhost>
	<20050427151010.GV8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Martin Hicks <mort@sgi.com> wrote:
>
> +#ifdef CONFIG_PAGE_OWNER /* huga... */
> + 	{
> +	unsigned long address, bp;
> +#ifdef X86_64
> +	asm ("movq %%rbp, %0" : "=r" (bp) : );
> +#else
> +        asm ("movl %%ebp, %0" : "=r" (bp) : );
> +#endif
> +        page->order = (int) order;
> +        __stack_trace(page, &address, bp);
> +	}
> +#endif /* CONFIG_PAGE_OWNER */

What's happening here, btw?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
