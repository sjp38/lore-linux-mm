Date: Tue, 13 Jun 2000 17:08:19 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <20000612232932.I15054@redhat.com>
Message-ID: <Pine.LNX.4.21.0006131700490.5590-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jun 2000, Stephen C. Tweedie wrote:

>Nice --- it might also explain some of the excessive kswap CPU 
>utilisation we've seen reported now and again.

You have more kswapd load for sure due the strict zone approch. It maybe
not noticeable but it's real. You boot, you allocate all the normal zone
in cache doing some fs load, then you start netscape and you allocate the
lower 16mbyte of RAM into it, then doing some other thing you trigger
kswapd to run because also the lower 16mbyte are been allocated now. Then
netscape exists and release all the lower 16m but kswapd keeps shrinking
the normal zone (this shouldn't happen and it wouldn't happen with
classzone design).

I think Linus's argument about the above scenario is simply that the above
isn't going to happen very often, but how can I ignore this broken
behaviour? I hate code that works in the common case but that have
drawbacks in the corner case. It would be better if I wouldn't know what
the current code is doing, then I could accept it more easily.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
