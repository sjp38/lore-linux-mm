Message-ID: <20000309175119.28794.qmail@web1306.mail.yahoo.com>
Date: Thu, 9 Mar 2000 09:51:19 -0800 (PST)
From: Andy Henroid <andy_henroid@yahoo.com>
Subject: Re: remap_page_range problem on 2.3.x
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

--- Jeff Garzik <jgarzik@mandrakesoft.com> wrote:
> Andy Henroid wrote:
> > 
> >                        Name: mmtest.tar.gz
> >    mmtest.tar.gz       Type: Unix Tape Archive
> (application/x-tar)
> >                    Encoding: base64
> >                 Description: mmtest.tar.gz
> 
> Are these the correct test files?
> 
> rum:~/tmp/mmtest> grep -i remap *
> rum:~/tmp/mmtest> 

Yes, the remap_page_range is done indirectly
through mmap call to the /dev/mem driver.

> I think you'll need to do something like
> 
> init():
> 	dsdt = get_free_pages(...)
> 
> chrdev mmap() op:
> 	remap_page_range(dsdt, ...)

OK, yes I bet that would work.  I just don't see
any good reason why the remap_page_range doesn't
appear to be doing the right thing for a piece
of kmalloced memory.

> If you are going to present data via /proc, you
> might as well simply dump the raw data out to
> whoever is reading /proc/driver/acpi/dsdt...

It's actually a bit less wasteful, for systems
with large DSDTs, to do the mmap.  But, right,
this is another possible work-around to my
current problem.

-Andy

__________________________________________________
Do You Yahoo!?
Talk to your friends online with Yahoo! Messenger.
http://im.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
