Date: Mon, 25 Sep 2000 13:08:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: refill_inactive()
In-Reply-To: <Pine.LNX.4.21.0009251631020.9122-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0009251306430.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Roger Larsson <roger.larsson@norran.net>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Ingo Molnar wrote:
> 
> On Mon, 25 Sep 2000, Rik van Riel wrote:
> 
> > 2) you are right, we /can/ schedule when __GFP_IO isn't set, this is
> >    mistake ... now I'm getting confused about what __GFP_IO is all
> >    about, does anybody know the _exact_ meaning of __GFP_IO ?
> 
> __GFP_IO set to 1 means that the allocator can afford doing IO implicitly
> by the page allocator. Most allocations dont care at all wether swap IO is
> started as part of gfp() or not. But a prominent counter-example is
> GFP_BUFFER, which is used by the buffer-cache/fs layer, and which cannot
> do any IO implicitly. (because it *is* the IO layer already, and it is
> already trying to do IO.) The other reason are legacy lowlevel-filesystem
> locks like the ext2fs lock, which cannot be taken recursively.

Hmmm, doesn't GFP_BUFFER simply imply that we cannot
allocate new buffer heads to do IO with??

(from reading buffer.c, I can't see much of a reason
why we couldn't start write IO on already allocated
buffers...)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
