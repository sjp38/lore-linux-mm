Date: Fri, 29 Sep 2000 17:12:58 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <E13f8CX-0001g1-00@the-village.bc.nu>
References: <20000929221109Z129234-481+1111@vger.kernel.org> from "Timur Tabi" at Sep 29, 2000 04:56:00 PM
Subject: Re: iounmap() - can't always unmap memory I've mappedt
Message-Id: <20000929221248Z131165-244+31@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Alan Cox <alan@lxorguk.ukuu.org.uk> on Fri, 29 Sep
2000 23:00:16 +0100 (BST)


> > "num_pages" is usually just equal to 1.  This code appears to work very well.
> > However, when I call the iounmap function on the memory obtained via
> > ioremap_nocache, sometimes I hit a kernel BUG().  The code which causes the bug
> > is in page_alloc.c, line 85 (in function  __free_pages_ok):
> > 
> > 	if (page->buffers)
> > 		BUG();
> 
> This sounds like you are trying to do maps on pages that are in use. No can do

Why not?  I mean, I can access the memory anyway from the driver, since it's
all mapped linearly via phys_to_virt.  All I'm really doing is creating a
temporary alias.

Unfortunately, this mapping is a requirement for our product.  I'd hate to have
to create my own pte's and do it all manually.

What confuses me is what ioremap_nocache() doesn't fail.  Why are these tests
(e.g. page->buffers) not in ioremap_nocache()?


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
