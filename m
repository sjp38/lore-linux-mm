Date: Tue, 11 Jul 2000 09:39:20 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: sys_exit() and zap_page_range()
Message-ID: <20000711093920.B1054@redhat.com>
References: <3965EC8E.5950B758@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3965EC8E.5950B758@uow.edu.au>; from andrewm@uow.edu.au on Sat, Jul 08, 2000 at 12:43:26AM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Jul 08, 2000 at 12:43:26AM +1000, Andrew Morton wrote:
> 
> Secondly, and quite unrelatedly, mmap002: why does the machine spend 10
> seconds pounding the disk during the exit() call? 

msync().

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
