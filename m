Date: Sun, 19 Jul 1998 00:10:09 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807131342.OAA06485@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980719000622.27620E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 1998, Stephen C. Tweedie wrote:

> I'm working on it right now.  Currently, the VM is so bad that it is
> seriously getting in the way of my job.  Just trying to fix some odd
> swapper bugs is impossible to test because I can't set up a ramdisk for
> swap and do in-memory tests that way: things thrash incredibly.  The
> algorithms for aggressive cache pruning rely on fractions of
> nr_physpages, and that simply doesn't work if you have large numbers of
> pages dedicated to non-swappable things such as ramdisk, bigphysarea DMA
> buffers or network buffers.

This means we'll have to substract those pages before
determining the used percentage.

> Rik, unfortunately I think we're just going to have to back out your
> cache page ageing.  I've just done that on my local test box and the
> results are *incredible*:

OK, I don't see much problems with that, except that the
aging helps a _lot_ with readahead. For the rest, it's
not much more than a kludge anyway ;(

We really ought to do better than that anyway. I'll give
you guys the URL of the Digital Unix manuals on this...
(they have some _very_ nice mechanisms for this)

> I'm going to do a bit more experimenting to see if we can keep some of
> the good ageing behaviour by doing proper LRU in the cache, but
> otherwise I think the cache ageing has either got to go or to be
> drastically altered.

A 2-level LRU on the page cache would be _very_ nice,
but probably just as desastrous wrt. fragmentation as
aging...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
