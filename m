Message-ID: <20000313191659.6976.qmail@web1306.mail.yahoo.com>
Date: Mon, 13 Mar 2000 11:16:59 -0800 (PST)
From: Andy Henroid <andy_henroid@yahoo.com>
Subject: Re: remap_page_range problem on 2.3.x
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Sailer <sailer@ife.ee.ethz.ch>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

--- Thomas Sailer <sailer@ife.ee.ethz.ch> wrote:
> Andy Henroid wrote:
> 
> > Yes, the remap_page_range is done indirectly
> > through mmap call to the /dev/mem driver.
> 
> I think I saw this too some time ago.
> 
> I tried to duplicate the kernel's view of the
> address space above 0xc0000000 at an offset in
> a usermode program. I ended up being able to
> read the correct data from /dev/mem, but reading
> from an mmaped page from /dev/mem returned
> completely bogus data (all zero).

Yes, the read through /dev/mem work for me too.
It looks like remap_page_range is doing the right
thing and it certainly works for other remapping.
I wonder what the problem is?

Oh well, low priority compared to the other things
that need to get fixed as we move into pre2.4

Thanks,
Andy

__________________________________________________
Do You Yahoo!?
Talk to your friends online with Yahoo! Messenger.
http://im.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
