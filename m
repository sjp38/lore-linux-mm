Date: Sun, 21 May 2000 01:14:13 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
In-Reply-To: <yttwvksvhqb.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005210112230.954-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm back from Canada, and finally have DSL at home, so I tried to sync up
with the patches I had in my in-queue. 

The mm patchs in particular didn't apply any more, because my tree did
some of the same stuff, so I did only a very very partial merge, much of
it to just make a full merge later simpler. I made it available under
testing as pre9-3, would you mind taking a look?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
