Message-Id: <200002081613.RAA09330@cave.bitwizard.nl>
Subject: Re: maximum memory limit
In-Reply-To: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home> from
 Rik van Riel at "Feb 8, 2000 03:08:49 pm"
Date: Tue, 8 Feb 2000 17:13:16 +0100 (MET)
From: R.E.Wolff@BitWizard.nl (Rogier Wolff)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Lee Chin <leechin@mail.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
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

Another thing to keep in mind is that to allow efficient
allocation/deallocation, there may be some rounding going on. The 2.0
kmalloc would round 1024 to 2048 and therefore waste almost half the
RAM.

> Problem is that libc malloc() appears to use brk() only, so

glibc will use mmap to implement "malloc". libc5 probably uses brk.

> it is limited to 900MB. You can fix that by doing the brk()
> and malloc() yourself, but I think that in the long run the
> glibc people may want to change their malloc implementation
> so that it automatically supports the full 3GB...

			Roger.
-- 
** R.E.Wolff@BitWizard.nl ** http://www.BitWizard.nl/ ** +31-15-2137555 **
*-- BitWizard writes Linux device drivers for any device you may have! --*
 "I didn't say it was your fault. I said I was going to blame it on you."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
