Date: Mon, 25 Sep 2000 14:30:34 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: virt_to_phys for ioremap'd memory
Message-Id: <20000925192431Z131283-10807+23@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Can anyone help me figure out how to do virtual->physical translation on memory
obtained via ioremap()?  I know that you need to have the physical address in
order to call ioremap(), but I don't want to have to remember the physical
address for all the memory blocks that I allocate via ioremap().  It'd be a lot
easier for me to do virt->phys translations on the virtual addresses whenever I
needed them.

I know it has something to do with walking the pgd/pmd/pte chain, but even
after looking at the kernel source code, I can't make heads or tails of it.

Thanks!


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
