Date: Fri, 13 Oct 2000 14:25:45 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
In-Reply-To: <20001013171950.Y6207@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.10.10010131424140.14888-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Richard Henderson <rth@twiddle.net>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "David S. Miller" <davem@redhat.com>, davej@suse.de, tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 13 Oct 2000, Jakub Jelinek wrote:

> On Fri, Oct 13, 2000 at 02:17:23PM -0700, Richard Henderson wrote:
> > On Fri, Oct 13, 2000 at 12:45:47PM +0100, Alan Cox wrote:
> > > Can we always be sure the rss will fit in an atomic_t - is it > 32bits on the
> > > ultrsparc/alpha ?
> > 
> > It is not.
> 
> It is not even 32bit on sparc32 (24bit only).

But remember that "rss" counts in pages, so it's plenty for sparc32: only
32 bits of virtual address  that can count towards the rss.

And even on alpha, a 32-bit atomic_t means we cover 45 bits of virtual
address space, which, btw, is more than you can cram into the current
three-level page tables, I think.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
