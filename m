Date: Tue, 26 Sep 2000 02:49:57 -0500 (CDT)
From: Jeff Garzik <jgarzik@mandrakesoft.mandrakesoft.com>
Subject: Re: virt_to_phys for ioremap'd memory
In-Reply-To: <20000925192431Z131283-10807+23@kanga.kvack.org>
Message-ID: <Pine.LNX.3.96.1000926024929.11108F-100000@mandrakesoft.mandrakesoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Timur Tabi wrote:

> Can anyone help me figure out how to do virtual->physical translation on memory
> obtained via ioremap()?  I know that you need to have the physical address in
> order to call ioremap(), but I don't want to have to remember the physical
> address for all the memory blocks that I allocate via ioremap().  It'd be a lot
> easier for me to do virt->phys translations on the virtual addresses whenever I
> needed them.
> 
> I know it has something to do with walking the pgd/pmd/pte chain, but even
> after looking at the kernel source code, I can't make heads or tails of it.

Instead of worry about that stuff, bite the bullet and remember the
physical addresses... :)

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
