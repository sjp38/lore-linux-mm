Message-ID: <3B1D5CDC.966285C1@earthlink.net>
Date: Tue, 05 Jun 2001 16:27:40 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: temp. mem mappings
References: <bYPDZD.A.c3.-gUH7@dinero.interactivesi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:
> 
> ** Reply to message from cohutta <cohutta@MailAndNews.com> on Tue, 5 Jun 2001
> 16:42:52 -0400
> 
> > I don't really want to play with the page tables if i can help it.
> > I didn't use ioremap() because it's real system memory, not IO bus
> > memory.
> >
> > How much normal memory is identity-mapped at boot on x86?
> > Is it more than 8 MB?
> 
> Much more.  Somewhere between 2 and 4 GB is mapped.  Large memory support in
> Linux has always confused me, so I can't remember exactly how much is mapped.

On x86, it's a little less than 1GB (4G-PAGE_OFFSET-<a little bit for
fixmaps,
kmap, vmalloc>); PAGE_OFFSET is 3GB by default. There is some stuff that
happens
before that mapping is done, though. All you can absolutely count on
when you
first enter 32-bit mode is the low 8MB. setup_arch() in
arch/i386/kernel/setup.c
is the place to look if you want to be sure; paging_init() is called
from there.

-- Joe
 

-- Joseph A. Knapka
"You know how many remote castles there are along the gorges? You
 can't MOVE for remote castles!" -- Lu Tze re. Uberwald
// Linux MM documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
