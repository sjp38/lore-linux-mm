Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 9A4FD38C5C
	for <linux-mm@kvack.org>; Mon, 30 Jul 2001 16:10:09 -0300 (EST)
Date: Mon, 30 Jul 2001 16:10:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Can reverse VM locks?
In-Reply-To: <Pine.LNX.4.33.0107022014190.9756-100000@alloc.wat.veritas.com>
Message-ID: <Pine.LNX.4.33L.0107301603120.5582-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: markhe@veritas.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

OK, I've been looking at the lock order reversal too,
though for different reasons ;)

On Mon, 2 Jul 2001 markhe@veritas.com wrote:
> On Mon, 2 Jul 2001, Rik van Riel wrote:
> > On Mon, 2 Jul 2001 markhe@veritas.com wrote:
> >
> > >   Anyone know of any places where reversing the lock ordering would break?
> >
> > Basically add_to_page_cache and remove_from_page cache and friends ;)
>
>   Hmm, does a page-cache page need to be on an LRU list?
>
>   If not, the 'add' case falls out OK; add it to the page-cache
> first, then add it to an LRU list _after_ dropping the
> pagecache_lock and taking the pagemap_lru_lock.  ie. no lock
> overlap.

Indeed, this would work. I've been looking at this too.

	[snip cool analysis]
> True?

Yes, very much true.  Now what I wanted to ask about:
do you already have a patch which does this or should
I write a patch which does the lock order reversal ?

cheers,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
