Date: Mon, 13 Mar 2000 12:31:33 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] mincore for i386, against 2.3.51
In-Reply-To: <Pine.BSO.4.10.10003131438050.12643-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.10.10003131229580.1257-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 13 Mar 2000, Chuck Lever wrote:
> > So I'd prefer something that does not have the "incore" function at all,
> > and if that convinces somebody else to change shm to use the address_space
> > stuff to get a working mincore(), all the better. Ok?
> 
> hmm.  i created the "incore" method because mincore needs to synchronize
> with the swapping method used for each of the different vma types.  this
> is different for shm's vs. mapped files -- they both use locking methods
> that are independent of one another.

But that's exactly my poing. The shm version is bad, and it will be
eventually removed ;)

> btw i think i've ended up in your kill file.  direct mail i send to you
> appears to be lost.

You'r enot in my kill-file any more than anybody else is.

The fact that I get too much mail means that very few people get horribly
much attention, I'm afraid.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
