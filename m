Date: Mon, 25 Sep 2000 17:21:44 -0400 (EDT)
From: Alexander Viro <aviro@redhat.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.LNX.4.10.10009242301230.1293-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10009251652530.4987-100000@aviro.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Theodore Y. Ts'o" <tytso@MIT.EDU>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Sun, 24 Sep 2000, Linus Torvalds wrote:

[directories in pagecache on ext2]

> > I'll do it and post the result tomorrow. I bet that there will be issues
> > I've overlooked (stuff that happens to work on UFS, but needs to be more
> > general for ext2), so it's going as "very alpha", but hey, it's pretty
> > straightforward, so there is a chance to debug it fast. Yes, famous last
> > words and all such...
> 
> Sure.

All right, I think I've got something that may work. Yes, there were issues -
UFS has the constant directory chunk size (1 sector), while ext2 makes it
equal to fs block size. _Bad_ idea, since the sector writes are atomic and
block ones... Oh, well, so ext2 is slightly less robust. It required some
changes, I'll do the initial testing and post the patch once it will pass
the trivial tests.

BTW, why on the Earth had we done it that way? It has no noticable effect
on directory fragmentation, it makes code (both in page- and buffer-cache
variants) more complex, it's less robust (by definition - directory layout
may be broken easier)... What was the point?

Not that we could do something about that now (albeit as a ro-compat feature
it would be nice), but I'm curious about the reasons...
							Cheers,
								Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
