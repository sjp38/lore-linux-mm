Date: Thu, 28 Apr 2005 13:41:17 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH/RFC 4/4] VM: automatic reclaim through mempolicy
Message-ID: <20050428174117.GJ19244@localhost>
References: <20050427145734.GL8018@localhost> <20050427151010.GV8018@localhost> <20050427165043.7ff66a19.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050427165043.7ff66a19.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, Apr 27, 2005 at 04:50:43PM -0700, Andrew Morton wrote:
> Martin Hicks <mort@sgi.com> wrote:
> >
> > +#ifdef CONFIG_PAGE_OWNER /* huga... */
> > + 	{
> > +	unsigned long address, bp;
> > +#ifdef X86_64
> > +	asm ("movq %%rbp, %0" : "=r" (bp) : );
> > +#else
> > +        asm ("movl %%ebp, %0" : "=r" (bp) : );
> > +#endif
> > +        page->order = (int) order;
> > +        __stack_trace(page, &address, bp);
> > +	}
> > +#endif /* CONFIG_PAGE_OWNER */
> 
> What's happening here, btw?

This is a direct copy from __alloc_pages().  Your guess is probably
better than mine.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
