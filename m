Date: Tue, 8 Feb 2000 16:25:01 +0100
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: maximum memory limit
Message-ID: <20000208162501.I532@mff.cuni.cz>
References: <381740616.949993193648.JavaMail.root@web36.pub01> <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home>; from Rik van Riel on Tue, Feb 08, 2000 at 03:08:49PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Lee Chin <leechin@mail.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 08, 2000 at 03:08:49PM +0100, Rik van Riel wrote:
> On Tue, 8 Feb 2000, Lee Chin wrote:
> 
> > Sorry if this is the wrong list, but what is the maximum virtual
> > memory an application can malloc in the latest kernel?
> > 
> > Just doing a (for example) "malloc(1024)" in a loop will max out
> > close to 1GB even though I have 4 GB ram on my system.
> 
> The kernel supports up to 3GB of address space per process.
> The first 900MB can be allocated by brk() and the rest can
> be allocated by mmap().
> 
> Problem is that libc malloc() appears to use brk() only, so
> it is limited to 900MB. You can fix that by doing the brk()
> and malloc() yourself, but I think that in the long run the
> glibc people may want to change their malloc implementation
> so that it automatically supports the full 3GB...

glibc malloc is able to use mmap, plus have a lot of tunable things.
See mallopt(3), particularly M_MMAP_THRESHOLD and M_MMAP_MAX parameters.
The default mmap threshold (above which malloc uses mmap) is I think 128K,
but you can decrease it. But it does not make much sense to decrease this
below PAGE_SIZE, because you then waste a lot of memory.

Cheers,
    Jakub
___________________________________________________________________
Jakub Jelinek | jakub@redhat.com | http://sunsite.mff.cuni.cz/~jj
Linux version 2.3.42 on a sparc64 machine (1343.49 BogoMips)
___________________________________________________________________
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
