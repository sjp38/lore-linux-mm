Date: Wed, 8 Mar 2000 19:26:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: Linux responsiveness under heavy load
In-Reply-To: <20000308223851.A9519@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0003081920500.4639-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Mar 2000, Jamie Lokier wrote:

	[snip awful performance under load]
> A larger boost to keep-the-page-in-memory priority for pages
> referenced by "interactive" processes might be in order.  
> Either faster vmscanning simply a higher priority for pages
> found to be used.  Might not be too hard to implement either.

Indeed it shouldn't be. Having a two-phase NRU unmapping in the
page table scanning and a maybe better LRU reclamation in
shrink_mmap() may help here, but the CPU cost may put some
people off...

Then again, not having this better memory reclamation is probably
more expensive than having it :)

Now where did I put that asbestos underwear?

> A larger priority for page-in I/O due to interactive process too
> might help too.  Some modification of Andrea's elevator.  But
> that doesn't seem so easy.

Read requests are easily tied to a process, so this could
be relatively easy. Doing it properly before 2.5 may be a
little difficult though ...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
