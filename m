Date: Wed, 14 Jun 2000 20:37:11 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006141424350.6887-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006142025290.377-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Rik van Riel wrote:

>Ermmm, I mean that trying to _balance_ the zone is the right
>thing to do. Consuming infinite CPU time when we can't succeed
>is a clear bug we want to fix.

Actually consuming CPU is the right thing to do. The other option is to
understand the zone is all mlocked and that it doesn't worth to waste CPU
there. If you're going to just break the kswapd loop after some time then
you're inserting a bug and you're making the VM even less robust.

What I was trying to explain is not how the VM reacts to too big mlocked
regions, but just how much the current design doesn't see the whole
picture about the property of the memory and how it ends doing something
very stupid in my testcase (the one first mlocked and then cache). The
fact it does something stupid is _only_ the sympthom. Whatever you do with
mlocked accounting can only fix the sympthom.

As soon as time permits I'll try to do another example of the current lack
of knowledge of the VM with respect to the property of the VM (and how
this ends doing yet other silly things). These emails are very expensive
in terms of time and I need to do some more real coding now ;).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
