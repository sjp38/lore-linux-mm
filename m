Date: Sat, 20 Jan 2001 18:05:12 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <14953.8856.982405.328564@pizda.ninka.net>
Message-ID: <Pine.LNX.4.31.0101201802080.1071-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jan 2001, David S. Miller wrote:
> Linus Torvalds writes:
>  >  - DO NOT WASTE TIME IF YOU HAVE MEMORY!
	[snip]
>  > This, btw, also implies: don't make the page tables more complex.
>
> I have to concur.

> Basically, that would leave us with the issue of choosing anonymous
> pages to tap out correctly.  I see nothing that prevents our page
> table scanning from being fundamentally unable to do quite well in
> this area.

I agree with this. However, having more uniform page aging
could lead to better page replacement and this pte chaining
thing is something I'd still like to try. ;)

If it turns out to be a win (with no measurable losses) I
may even submit a patch, but if it turns out to be a loss
I'll just drop the idea...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
