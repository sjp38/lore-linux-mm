Date: Wed, 7 Jun 2000 10:23:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <20000607121555.G29432@redhat.com>
Message-ID: <Pine.LNX.4.21.0006071018320.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <hans@reiser.to>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Stephen C. Tweedie wrote:
> On Tue, Jun 06, 2000 at 08:45:08PM -0700, Hans Reiser wrote:
> > > 
> > > This is the reason because of what I think that one operation in the
> > > address space makes no sense.  No sense because it can't be called
> > > from the page.
> > 
> > What do you think of my argument that each of the subcaches should register
> > currently_consuming counters which are the number of pages that subcache
> > currently takes up in memory,
> 
> There is no need for subcaches at all if all of the pages can be
> represented on the page cache LRU lists.  That would certainly
> make balancing between caches easier.

Wouldn't this mean we could end up with an LRU cache full of
unfreeable pages?

Then we would scan the LRU cache and apply pressure on all of
the filesystems, but then the filesystem could decide it wants
to flush *other* pages from the ones we have on the LRU queue.

This could get particularly nasty when we have a VM with
active / inactive / scavenge lists... (like what I'm working
on now)

Then again, if the filesystem knows which pages we want to
push, it could base the order in which it is going to flush
its blocks on that memory pressure. Then your scheme will
undoubtedly be the more robust one.

Question is, are the filesystems ready to play this game?

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
