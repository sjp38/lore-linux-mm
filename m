Date: Thu, 4 May 2000 16:00:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <Pine.LNX.4.10.10005041137320.1388-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005041559490.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Linus Torvalds wrote:

> Note that changing how hard try_to_free_pages() tries to free a page is
> exactly part of what Rik has been doing, so this is something that has
> changed recently. It's not trivial to get right, for a very simple reason:
> we need to balance the "hardness" between the VM area scanning and the RLU
> list scanning.

With the current scheme, it's pretty much impossible to get it
right.

> Rik probably balanced it ok, but ended up making it too soft,
> giving up much too easily even when memory really would be
> available if it were to just try a bit harder..

*nod*

I hope the active/inactive page list scheme will fix this.

(we can push harder since we'll have pages in every stage
of aging every time)

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
