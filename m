Date: Tue, 25 Apr 2000 16:34:24 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
In-Reply-To: <20000425120657.B7176@stormix.com>
Message-ID: <Pine.LNX.4.21.0004251630180.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Kirby <sim@stormix.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Simon Kirby wrote:

> Sorry, I made a mistake there while writing..I was going to give an
> example and wrote 60 seconds, but I didn't actually mean to limit
> anything to 60 seconds.  I just meant to make a really big global lru
> that contains everything including page cache and swap. :)

We already have that big global lru queue (actually, it's a 
bit more closer to second chance replacement).

For pages which are in the page tables of processes, we
put the pages on the queue when we scan them and they
weren't used since we scanned them the last time (NRU
replacement). After that, they go through the lru queue
and are reclaimed when it's their turn.

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
