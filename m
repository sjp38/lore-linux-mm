Date: Wed, 3 May 2000 09:14:28 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <200005031608.JAA87583@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10005030911200.5951-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 3 May 2000, Kanoj Sarcar wrote:
> > So "is_page_shared()" can be entirely crap. And can tell shrink_mmap()
> 
> Not really ... look at other places that call is_page_shared, they all
> hold the pagelock. shrink_mmap does not bother with is_page_shared logic.

That wasn't my argument.

My argument is that yes, the _callers_ of is_page_shared() all hold the
page lock. No question about that. But the things that is_page_shared()
actually tests can be modified without holding the page lock, so the page
lock doesn't actually _protect_ it. See?

So the callers might as well hold one of the networking spinlocks - it
just doesn't matter as a lock, because the places that modify the stuff do
not care about the lock.. And that is fishy.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
