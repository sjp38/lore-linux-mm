Date: Wed, 7 Jun 2000 09:43:50 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
In-Reply-To: <qww1z29ssbb.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0006070939330.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7 Jun 2000, Christoph Rohland wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> 
> > Awaiting your promised integration of SHM with the shrink_mmap
> > queue...
> 
> Sorry Rik, there was a misunderstanding here. I would really
> like to have this integration. But AFAICS this is a major task.
> shrink_mmap relies on the pages to be in the page cache and the
> pagecache does not handle shared anonymous pages.

Ahh, but it could easily swap them out when the last of the
pages is unmapped.

if (PageSHM(page) && not_in_use(page) && PageDirty(page)) {
	swapentry_t entry;
	entry.val = alloc_swap_entry();
	....
	rw_swap_page(page);
}

And the next time it can be freed like a normal SwapCache
page...

> Thus shm does it's own page handling and swap out mechanism.
> Since I do not know enough about the page cache I will not do
> this before 2.5. If you think it can be easily done, feel free
> to do it yourself or show me the way to go (But I will be on
> vacation the next two weeks).

OK. The shrink_mmap() side of the story should be relatively
easy (see above), but the ipc/shm.c part is a complete mystery
to me ... ;(

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
