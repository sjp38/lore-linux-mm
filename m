Date: Wed, 17 Jan 2001 15:54:04 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.10.10101081903450.1371-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.31.0101171551090.5464-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jan 2001, Linus Torvalds wrote:

>  - gets rid of the complex "best mm" logic and replaces it with the
>    round-robin thing as discussed.

This could help IO clustering as well, which should be good
whenever we want to swap the data back in ;)

>  - it cleans up and simplifies the MM "priority" thing. In fact, right now
>    only one priority is ever used,

Sounds great.

In the week that I've been offline I have been working on
page_launder and doing a few other improvements to the VM.

Once I get the time to clean everything up I think we can
take 2.4 to a slightly better performance level without
having to change anything big.

regards,

Rik (at linux.conf.au)
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
