Date: Wed, 26 Apr 2000 08:15:14 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
In-Reply-To: <20000426120130.E3792@redhat.com>
Message-ID: <Pine.LNX.4.21.0004260814130.16202-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Simon Kirby <sim@stormix.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000, Stephen C. Tweedie wrote:
> On Tue, Apr 25, 2000 at 12:06:58PM -0700, Simon Kirby wrote:
> > 
> > Sorry, I made a mistake there while writing..I was going to give an
> > example and wrote 60 seconds, but I didn't actually mean to limit
> > anything to 60 seconds.  I just meant to make a really big global lru
> > that contains everything including page cache and swap. :)
> 
> Doesn't work.  If you do that, a "find / | grep ..." swaps out 
> everything in your entire system.
> 
> Getting the VM to respond properly in a way which doesn't freak out
> in the mass-filescan case is non-trivial.  Simple LRU over all pages
> simply doesn't cut it.

It seems to work pretty well, because pages "belonging to" processes
are mapped into the address space of each process and will never go
through swap_out() if shrink_mmap() will succeed.

regards,

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
