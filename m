From: dca@torrent.com
Date: Sun, 8 Aug 1999 14:02:25 -0400
Message-Id: <199908081802.OAA23738@grappelli.torrent.com>
Subject: Re: getrusage
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: grg22@ai.mit.edu, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> You need another [new entry]: a vm id.

I'm missing something here.  Isn't the vmid implicit in the caller's
context?  That is, if I call getrusage, I'm asking about "my" vm
statistics.  /proc and gtop are sources of information about other
contexts.

> There is already a patch floating around on l-k that does that,
> although it reports via a /proc entry per process. Integrating it in
> rusage would be a nice addition. The possible unique ids are memory
> address of the kernel mm_struct (ugly, but zero cost), or the pid of
> the process who created the VM first.

> If you do fix this, could you please make all these entries
> *unsigned* longs?

Taking a hint from Solaris' treatment of getrlimit, how 'bout:

  typedef unsigned long rusage_t;

for the flexibility?

Is there interest in providing max values for the individual kinds of
memory (shared/data/stack) in addition to the overall maxrss?  It's
not what I need, and other implementations don't provide it.  They
don't even provide current values, only useless "integrals".

By the sound of it, I have maybe a week to produce something
acceptable if I want to see it in 2.4.  Is that about right?

-dca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
