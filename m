Date: Fri, 7 Apr 2000 09:54:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004071356590.325-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004070950570.23401-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Andrea Arcangeli wrote:
> On Fri, 7 Apr 2000, Rik van Riel wrote:
> 
> >Please use the clear_bit() macro for this, the code is
> >unreadable enough in its current state...
> 
> I didn't used the ClearPageSwapEntry macro to avoid executing
> locked asm instructions where not necessary.

Hmmmmm...

Won't this screw up when another processor is atomically
setting the bit just after we removed it and we still have
it in the store queue?

from include/asm-i386/spinlock.h
/*
 * Sadly, some early PPro chips require the locked access,
 * otherwise we could just always simply do
 *
 *      #define spin_unlock_string \
 *              "movb $0,%0"
 *
 * Which is noticeably faster.
 */

I don't know if it is relevant here, but would like to
be sure ...

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
