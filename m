Date: Thu, 2 Dec 1999 09:50:40 -0500 (EST)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: set_pte() is no longer atomic with PAE36.
In-Reply-To: <E11tXRX-0000sQ-00@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.991202094907.5465A-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 1999, Alan Cox wrote:

> > Modifying an existing pte (eg. for COW) is probably even harder: do we
> > need to clear the page-present bit while we modify the high word?
> > Simply setting the dirty or accessed bits should pose no such problem,
> > but relocating a page looks as if it could bite here.
> 
> You can do 64bit atomic sets with lock cmpxchg8. It might just be slow though

unmaps are not fast anyway (i mean we are not counting cycles there), and
this is absolutely needed for correctness. First correctness then speed. 
Last i timed cmpxchg8b it wasnt that terribly slow - it had the slowness
of LOCK-ed instructions, but nothing dramatic. 

-- mingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
