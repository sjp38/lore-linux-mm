Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id E465638C73
	for <linux-mm@kvack.org>; Tue, 31 Jul 2001 06:51:52 -0300 (EST)
Date: Tue, 31 Jul 2001 06:51:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: strange locking __find_get_swapcache_page()
In-Reply-To: <Pine.LNX.4.33.0107301839440.19638-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0107310639480.5582-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <andrewm@uow.edu.au>, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2001, Linus Torvalds wrote:
> On Mon, 30 Jul 2001, Rik van Riel wrote:
> >
> > I've encountered a suspicious piece of code in filemap.c:
> >
> > struct page * __find_get_swapcache_page( ... )
>
> Hmm. I thin the whole PageSwapCache() test is bogus - if we
> found it on the swapper_space address space, then the page had
> better be a swap-cache page, and testing for it explicitly is
> silly.

*nod*

> Also, it appears that the only caller of this is
> find_get_swapcache_page(), which in itself really doesn't even

It's even simpler than that.  The only user is lookup_swap_cache(),
which is used only to see if a page is present in the swap cache
or not ...

regards,

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
