Date: Mon, 13 Mar 2000 10:35:55 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] mincore for i386, against 2.3.51
In-Reply-To: <200003131828.KAA82343@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10003131032290.1257-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I don't like the "incore" thing.

I think that "incore" should be a generic VM function, and be based solely
on the VMA and the associated address space. 

The fact that the current shared memory implementation doesn't use address
spaces is an acknowledged bug and misfeature, not an excuse to perpetuate
the problem..

So I'd prefer something that does not have the "incore" function at all,
and if that convinces somebody else to change shm to use the address_space
stuff to get a working mincore(), all the better. Ok?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
