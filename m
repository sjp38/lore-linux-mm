Date: Fri, 12 Jan 2001 20:41:41 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.10.10101121617230.8097-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101122038420.10842-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 12 Jan 2001, Linus Torvalds wrote:

> If the page truly is new (because of some other user), then page_launder()
> won't drop it, and it doesn't matter. But dropping it from the VM means
> that the list handling can work right, and that the page will be aged (and
> thrown out) at the same rate as other pages.

What about the amount of faults this potentially causes? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
