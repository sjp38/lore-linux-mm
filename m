Date: Mon, 20 Mar 2000 13:31:28 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] first bit of vm balancing fixes for 2.3.52-1
In-Reply-To: <200003202058.MAA47885@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10003201329470.4818-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 20 Mar 2000, Kanoj Sarcar wrote:
> > 
> > The current behaviour is highly suboptimal: if you have two zones to
> > pick from for a given alloc_page(), and the first zone is at its
> > pages_min threshold, then we will always allocate from that first zone
> > and push it into kswap activation no matter how much free space there is
> > in the next zone.
> 
> With Linus' change to the page alloc code in pre2, yes, spreading
> the allocation is an option, but I would be real careful before 
> putting that in 2.4.

It's not an option: it is how things work.

My code expliticly says: ok, walk the list of zones, if any of them have
plenty of memory free just allocate it.

Only if none of the zones is an obvious target for allocation do we
balance, and then we mark all the appropriate zones for balancing at once.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
