Date: Tue, 17 Apr 2001 13:42:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Ideas for adding physically contiguous memory support to mmap()??
Message-ID: <20010417134251.B2505@redhat.com>
References: <C78C149684DAD311B757009027AA5CDC094DA2A8@xboi02.boi.hp.com> <Pine.LNX.3.96.1010410191553.22333A-100000@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.3.96.1010410191553.22333A-100000@kanga.kvack.org>; from blah@kvack.org on Tue, Apr 10, 2001 at 07:24:12PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "LUTZ,TODD (HP-Boise,ex1)" <tlutz@hp.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 10, 2001 at 07:24:12PM -0400, Benjamin C.R. LaHaise wrote:
> On Tue, 10 Apr 2001, LUTZ,TODD (HP-Boise,ex1) wrote:
> 
> > 1. Able to specify any size that is a multiple of PAGE_SIZE (not just powers
> > of 2).
> 
> First off: why do you need this functionality?  It does not sound like it
> provides any significant benefits over the current system once you take
> into consideration the effects it will have on memory fragmentation.

Indeed.  Most of the motivation for large contiguous memory areas in
user space are concerned with cache line colouring and efficient use
of tlbs.  An API for large page support and kernel support for cache
colouring would be nice, but in general the more of this that can be
done opportunistically (without any application API changes), the
better.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
