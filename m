Message-ID: <396B0408.3773A5B6@uow.edu.au>
Date: Tue, 11 Jul 2000 21:24:56 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: sys_exit() and zap_page_range()
References: <3965EC8E.5950B758@uow.edu.au>,
            <3965EC8E.5950B758@uow.edu.au>; from andrewm@uow.edu.au on Sat,
            Jul 08, 2000 at 12:43:26AM +1000 <20000711093920.B1054@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Sat, Jul 08, 2000 at 12:43:26AM +1000, Andrew Morton wrote:
> >
> > Secondly, and quite unrelatedly, mmap002: why does the machine spend 10
> > seconds pounding the disk during the exit() call?
> 
> msync().

Nope.  Take out the msyncs and it still does it.

But with or without msync(), the file has been closed and unlinked when
mmap002 exits.  Hence all those blocks are unreferenced and free.  There
seems to be no need to write them back.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
