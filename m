Subject: Re: iounmap() - can't always unmap memory I've mappedt
Date: Fri, 29 Sep 2000 23:00:16 +0100 (BST)
In-Reply-To: <20000929221109Z129234-481+1111@vger.kernel.org> from "Timur Tabi" at Sep 29, 2000 04:56:00 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13f8CX-0001g1-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> "num_pages" is usually just equal to 1.  This code appears to work very well.
> However, when I call the iounmap function on the memory obtained via
> ioremap_nocache, sometimes I hit a kernel BUG().  The code which causes the bug
> is in page_alloc.c, line 85 (in function  __free_pages_ok):
> 
> 	if (page->buffers)
> 		BUG();

This sounds like you are trying to do maps on pages that are in use. No can do

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
