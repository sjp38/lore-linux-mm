Date: Sat, 6 May 2000 15:31:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: PG_referenced and lru_cache (cpu%)...
In-Reply-To: <39147CB9.256D1EEA@norran.net>
Message-ID: <Pine.LNX.4.21.0005061529280.4627-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 May 2000, Roger Larsson wrote:

> When _add_to_page_cache adds a page to the lru_cache
> it forces it to be referenced.
> In addition it will be added as youngest in list.

Which is IMHO a good thing, since the page *was* referenced
and was referenced last.

> When a page is needed it is very likely that a lot of
> the youngest pages are marked as referenced.

> order=0 is the only that tries to search the full list.

No. Referenced pages are not counted, so if we encounter
a lot of them we will happily age them all without decreasing
the value of count.

> When the shrink_mmap finds PG_referenced pages they are
> moved to local list young and will not be inserted before
> shink_mmap returns, again does not matter...

So the next time shrink_mmap() is called, we'll free the
page.

> Conclusion:

	[snip]

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
