Date: Fri, 21 Jul 2000 08:51:41 -0500 (CDT)
From: Jeff Garzik <jgarzik@mandrakesoft.mandrakesoft.com>
Subject: Re: Marking a physical page as uncacheable
In-Reply-To: <20000720200754Z131167-4584+7@kanga.kvack.org>
Message-ID: <Pine.LNX.3.96.1000721085044.5477C-100000@mandrakesoft.mandrakesoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jul 2000, Timur Tabi wrote:
> ** Reply to message from Manfred Spraul <manfred@colorfullife.com> on Thu, 20
> Jul 2000 18:16:56 +0200
> > You could use ClearPageReserved() + ioremap(), but ioremap() is limited
> > to the first 4 GB.
> 
> Is there an ioUNremap()?  I need to perform tests on the memory region with the

It's called iounmap.  Please take a look at drivers which use the
functions are you interested in...  Also look at the docs :)
Documentation/IO-mapping.txt would be particularly helpful in this
instance.

	Jeff




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
