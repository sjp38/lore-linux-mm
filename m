Message-ID: <397725F8.34744F7A@colorfullife.com>
Date: Thu, 20 Jul 2000 18:16:56 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: Marking a physical page as uncacheable
References: <20000719181648Z131171-4588+3@kanga.kvack.org> <20000720154702Z131167-4587+7@kanga.kvack.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:
> 
> ** Reply to message from Mark Mokryn <mark@sangate.com> on Thu, 20 Jul 2000
> 17:36:39 +0300
> 
> > Try ioremap_nocache()
> 
> That's just a front-end to __ioremap().  I'm trying to make REAL RAM as
> uncacheable, not PCI memory.  ioremap() does not work on real RAM, only high
> addresses outside of physical memory.
> 

You could use ClearPageReserved() + ioremap(), but ioremap() is limited
to the first 4 GB.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
