From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14953.8856.982405.328564@pizda.ninka.net>
Date: Fri, 19 Jan 2001 21:31:04 -0800 (PST)
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <Pine.LNX.4.10.10101192108150.2760-100000@penguin.transmeta.com>
References: <Pine.LNX.4.31.0101191849050.3368-100000@localhost.localdomain>
	<Pine.LNX.4.10.10101192108150.2760-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds writes:
 >  - DO NOT WASTE TIME IF YOU HAVE MEMORY!
 > 
 > The second point is important. You have to really think about how Linux
 > handles anonymous pages, and understand that that is not just an accident.
 > It's really important to NOT do extra work for the case where an
 > application just wants a page. Don't allocate swap backing store early.
 > Don't add it to the page cache if it doesn't need to be there. Don't do
 > ANYTHING.
 > 
 > This, btw, also implies: don't make the page tables more complex.

I have to concur.  The more I think about the whole idea of
pte-chaining the more I dislike it and think work on it is a waste of
time.  I can say this, being that I actually tried once to fully make
such a scheme work.

My old gripe and incentive to do such things has honestly
disappeared.  The big issue was cache aliasing problems on
some silly cpus, but the current recommented APIs described
in Documentation/cachetlb.txt can handle such situations quite
acceptably.

Basically, that would leave us with the issue of choosing anonymous
pages to tap out correctly.  I see nothing that prevents our page
table scanning from being fundamentally unable to do quite well in
this area.  Sure, true LRU aging of anonymous pages alongside all the
other reclaimable pages in the system is not possible now, but I
cannot provably show that this is actually required for good behavior.

-DaveM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
