Message-ID: <38B52CC0.7AC1169E@intermec.com>
Date: Thu, 24 Feb 2000 14:06:08 +0100
From: lars brinkhoff <lars.brinkhoff@intermec.com>
MIME-Version: 1.0
Subject: Re: mmap/munmap semantics
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
		<14516.11124.729025.321352@dukat.scot.redhat.com>
		<20000224033502.B6548@pcep-jamie.cern.ch> <14517.8311.194809.598957@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> On Thu, 24 Feb 2000 03:35:02 +0100, Jamie Lokier
> <lk@tantalophile.demon.co.uk> said:
> > I don't think MADV_DONTNEED actually drops privately modified data does
> > it?
> Yes, it does.  From the DU man pages:
> 
>       MADV_DONTNEED
>                       Do not need these pages
> 
>                       The system will free any whole pages in the specified
>                       region.  All modifications will be lost and any swapped
>                       out pages will be discarded.  Subsequent access to the
>                       region will result in a zero-fill-on-demand fault as
>                       though it is being accessed for the first time.
>                       Reserved swap space is not affected by this call.

>From a FreeBSD man page at
http://dorifer.heim3.tu-clausthal.de/cgi-bin/man/madvise.2.html

     MADV_DONTNEED    Allows the VM system to decrease the in-memory priority
                      of pages in the specified range.  Additionally future
                      references to this address range will incur a page
                      fault.

     MADV_FREE        Gives the VM system the freedom to free pages, and tells
                      the system that information in the specified page range
                      is no longer important.  This is an efficient way of al-
                      lowing malloc(3) to free pages anywhere in the address
                      space, while keeping the address space valid.  The next
                      time that the page is referenced, the page might be de-
                      mand zeroed, or might contain the data that was there
                      before the MADV_FREE call.  References made to that ad-
                      dress space range will not make the VM system page the
                      information back in from backing store until the page is
                      modified again.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
