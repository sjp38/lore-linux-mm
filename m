Message-ID: <20021004152343.65188.qmail@web12801.mail.yahoo.com>
Date: Fri, 4 Oct 2002 08:23:43 -0700 (PDT)
From: sreekanth reddy <reddy_cdi@yahoo.com>
Subject: Re: remap_page_range() beyond 4GB
In-Reply-To: <20021004110300.B1269@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ben..

I want to map the contiguous physical pages (>4GB RAM)
that I've allocated into user space. I've also looked
into kmap(), kmap_high() that return kernel virtual
addresses k(addr)but how do I map kaddr into user
address space ? Thanks..

Sreekanth Reddy


--- Benjamin LaHaise <bcrl@redhat.com> wrote:
> On Fri, Oct 04, 2002 at 06:42:59AM -0700, sreekanth
> reddy wrote:
> > How can I "remap_page_range()" for physical
> addresses
> > beyond 4GB ? . remap_page_range()takes a 32 bit
> > (unsigned long) value which cannot address > 4GB
> > physical memory.
> 
> What are you using remap_page_range() on?  It should
> never be used on 
> RAM.
> 
> 		-ben
> --
> To unsubscribe, send a message with 'unsubscribe
> linux-mm' in
> the body to majordomo@kvack.org.  For more info on
> Linux MM,
> see: http://www.linux-mm.org/


__________________________________________________
Do you Yahoo!?
New DSL Internet Access from SBC & Yahoo!
http://sbc.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
