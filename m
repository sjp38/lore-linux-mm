Date: Mon, 23 Oct 2000 18:13:48 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Another wish item for your TODO list...
In-Reply-To: <20001023203853.A3295@redhat.com>
Message-ID: <Pine.LNX.4.21.0010231810220.13115-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Oct 2000, Stephen C. Tweedie wrote:
> On Mon, Oct 23, 2000 at 04:07:02PM -0200, Rik van Riel wrote:
> 
> > > It's an optimisation in CPU time as much as for anything else:
> > > there's just no point in doing expensive memory balancing/aging
> > > for pages which we know are next to useless.
> > 
> > The problem here is that we shouldn't remove the pages which are
> > in the current readahead window, as those /will/ most likely be
> > used in the near future.
> 
> It probably only makes real sense to do this for inodes which
> are not in use, anyway, which avoids that problem completely.

FreeBSD has a neat solution for this:

- if the memory item (file, shm segment, ...) is in use, move
  the page to the inactive list (equivalent to our inactive_dirty)
- if the item isn't in use, move the page to the cache list
  (equivalent to our inactive_clean list)

We could extend this by moving *every* page of an item which
isn't in use to the inactive_clean list once we move ONE page
of such an item to that list (or reclaim it?).

[IMHO we don't want to free the page ... no need to throw away
the data in the page too soon]

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
