Received: from m-net.arbornet.org (m-net.arbornet.org [209.142.209.161])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA30746
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 05:38:49 -0400
Date: Mon, 5 Apr 1999 05:12:50 -0400 (EDT)
From: Amol Mohite <amol@m-net.arbornet.org>
Subject: Re: Somw questions [ MAYBE OFFTOPIC ]
In-Reply-To: <19990402113555.F9584@uni-koblenz.de>
Message-ID: <Pine.BSI.3.96.990405050919.3415A-100000@m-net.arbornet.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: ralf@uni-koblenz.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> A NULL pointer is just yet another invalid address.  There is no special
> test for a NULL pointer.  Most probably for example (char *)0x12345678 will
> be invalid as a pointer as well and treated the same.  The CPU detects this
> when the TLB doesn't have a translation valid for the access being attempted.
> 


Yes but how does it know it is a null pointer ?

On that note, when c does not allow u to dereference a void pointer , is
this compiler  doing the trick ?

Ok , about the expand down attribute, thats how 32 bit windows does it, so
i was wondering if linux also does the same.

16 bit windows accesses a null pointer with a 0: descriptor.

Apparently intel allows u to load a 0 but not dererence it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
