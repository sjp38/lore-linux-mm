Date: Tue, 11 Jul 2000 14:35:58 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: sys_exit() and zap_page_range()
Message-ID: <20000711143558.E1054@redhat.com>
References: <3965EC8E.5950B758@uow.edu.au>, <3965EC8E.5950B758@uow.edu.au>; <20000711093920.B1054@redhat.com> <396B0408.3773A5B6@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <396B0408.3773A5B6@uow.edu.au>; from andrewm@uow.edu.au on Tue, Jul 11, 2000 at 09:24:56PM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jul 11, 2000 at 09:24:56PM +1000, Andrew Morton wrote:
> 
> Nope.  Take out the msyncs and it still does it.

Unmapping a writable region results in an implicit msync.  That
includes exit() and munmap().
 
> But with or without msync(), the file has been closed and unlinked when
> mmap002 exits.

Have all mappings been unmapped, though?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
