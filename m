Date: Tue, 8 Feb 2000 15:08:49 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: maximum memory limit
In-Reply-To: <381740616.949993193648.JavaMail.root@web36.pub01>
Message-ID: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Chin <leechin@mail.com>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Feb 2000, Lee Chin wrote:

> Sorry if this is the wrong list, but what is the maximum virtual
> memory an application can malloc in the latest kernel?
> 
> Just doing a (for example) "malloc(1024)" in a loop will max out
> close to 1GB even though I have 4 GB ram on my system.

The kernel supports up to 3GB of address space per process.
The first 900MB can be allocated by brk() and the rest can
be allocated by mmap().

Problem is that libc malloc() appears to use brk() only, so
it is limited to 900MB. You can fix that by doing the brk()
and malloc() yourself, but I think that in the long run the
glibc people may want to change their malloc implementation
so that it automatically supports the full 3GB...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
