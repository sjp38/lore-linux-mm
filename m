Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA10860
	for <linux-mm@kvack.org>; Fri, 16 Apr 1999 14:20:34 -0400
Date: Sat, 17 Apr 1999 13:12:08 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.SCO.3.94.990405122223.26431B-100000@tyne.london.sco.com>
Message-ID: <Pine.LNX.4.05.9904171240040.623-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mark Hemment <markhe@sco.COM>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>, "Stephen C. Tweedie" <sct@redhat.com>, Chuck Lever <cel@monkey.org>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Mark Hemment wrote:

>  The page structure needs to be as small as possible.  If its size
>happens to L1 align, then that is great, but otherwise it isn't worth the
>effort - the extra memory used to store the "padding" is much better used
>else where.
>  Most accesses to the page struct are reads, this means it can live in
>the Shared state across mutilple L1 caches.  The "slightly" common
>operation of incremented the ref-count/changing-flag-bits doesn't really
>come into play often enough to matter.
>  Keeping the struct small can result in part of the page struct of
>interest in the L1 cache, along with part of the next one.  As it isn't a
>heavily modified structure, with no spin locks, "false sharing" isn't a
>problem.  Besides, the VM isn't threaded, so it isn't going to be playing
>ping-pong with the cache lines anyway.

I think the same thing applys to many places where we are using the slab
and we are right now requesting L1 cache alignment but the code is not
going to be SMP threaded for real (no spinlocks in the struct or/and
everything protected by the big kernel lock).

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
