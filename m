Received: from mailhost.uni-koblenz.de (mailhost.uni-koblenz.de [141.26.64.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA17215
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 16:53:35 -0400
Received: from lappi.waldorf-gmbh.de (cacc-8.uni-koblenz.de [141.26.131.8])
	by mailhost.uni-koblenz.de (8.9.1/8.9.1) with ESMTP id WAA19712
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 22:53:27 +0200 (MET DST)
Message-ID: <19990406125558.C3742@uni-koblenz.de>
Date: Tue, 6 Apr 1999 12:55:58 +0200
From: ralf@uni-koblenz.de
Subject: Re: Somw questions [ MAYBE OFFTOPIC ]
References: <19990402113555.F9584@uni-koblenz.de> <Pine.BSI.3.96.990405050919.3415A-100000@m-net.arbornet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSI.3.96.990405050919.3415A-100000@m-net.arbornet.org>; from Amol Mohite on Mon, Apr 05, 1999 at 05:12:50AM -0400
Sender: owner-linux-mm@kvack.org
To: Amol Mohite <amol@m-net.arbornet.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 1999 at 05:12:50AM -0400, Amol Mohite wrote:

> > A NULL pointer is just yet another invalid address.  There is no special
> > test for a NULL pointer.  Most probably for example (char *)0x12345678
> > will be invalid as a pointer as well and treated the same.  The CPU
> > detects this when the TLB doesn't have a translation valid for the
> > access being attempted.
> 
> Yes but how does it know it is a null pointer ?

Again, it doesn't know that it is a *NULL* pointer.  The kernel just knows
that a user program resulted in the CPU throwing an exception for attempting
an illegal access, that is insufficient permissions for the mapping or
no mapping for the address at all.

> On that note, when c does not allow u to dereference a void pointer , is
> this compiler doing the trick ?

Only ANSI/ISO C doesn't allow to dereference void pointers, GCC allows this
as an extension of the language.  Most machines only have untyped pointers,
for them void * or not would only a difference to the compiler, not the
machine - if the compiler allows it.

> Ok , about the expand down attribute, thats how 32 bit windows does it, so
> i was wondering if linux also does the same.
> 
> 16 bit windows accesses a null pointer with a 0: descriptor.
> 
> Apparently intel allows u to load a 0 but not dererence it.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
