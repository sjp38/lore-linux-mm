Date: Mon, 23 Oct 2000 16:07:02 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Another wish item for your TODO list...
In-Reply-To: <20001023183649.H2772@redhat.com>
Message-ID: <Pine.LNX.4.21.0010231559230.13115-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Oct 2000, Stephen C. Tweedie wrote:
> On Mon, Oct 23, 2000 at 03:02:06PM -0200, Rik van Riel wrote:
> > 
> > > Just a quick thought --- at some point it would be good if we
> > > could add logic to the core VM so that for sequentially accessed
> > > files, reclaiming any page of the file from cache would evict
> > > the _whole_ of the file from cache.
> > 
> > I take it you mean "move all the pages from before the
> > currently read page to the inactive list", so we preserve
> > the pages we just read in with readahead ?
> 
> No, I mean that once we actually remove a page, we should also remove
> all the other pages IF the file has never been accessed in a
> non-sequential manner.  The inactive management is separate.
> 
> It's an optimisation in CPU time as much as for anything else:
> there's just no point in doing expensive memory balancing/aging
> for pages which we know are next to useless.

The problem here is that we shouldn't remove the pages which are
in the current readahead window, as those /will/ most likely be
used in the near future.

One option could be to free all inactive pages in the address
space of that file, but we'd still need to go around and find
them...

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
