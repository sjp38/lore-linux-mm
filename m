Subject: Re: [Patch] shm cleanups
References: <Pine.LNX.4.10.9911042319530.8880-100000@chiara.csoma.elte.hu>
From: Andrea Arcangeli <andrea@suse.de>
Date: 05 Nov 1999 01:14:04 +0100
In-Reply-To: Ingo Molnar's message of "Thu, 4 Nov 1999 23:30:01 +0100 (CET)"
Message-ID: <m3yacd23sj.fsf@alpha.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Rik van Riel <riel@nl.linux.org>, Christoph Rohland <hans-christoph.rohland@sap.com>, MM mailing list <linux-mm@kvack.org>, woodman@missioncriticallinux.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@chiara.csoma.elte.hu> writes:

> [Christoph, are you still seeing the same kind of bad swapping behavior
> with pre1-2.3.26?]

If you still get process killed during heavy swapout (cause OOM of
an ATOMIC allocation) please try to increase the ATOMIC pool before
designing a separate pool. We just have a pool for atomic allocation
it may not be large enough for the increased pressure on the regular pages.

        echo 1000 2000 4000 >/proc/sys/vm/freepages

This way you'll basically waste 16mbyte of ram.  It's just to check if
the ATOMIC allocation shortage is the source of the segfault or not.

-- 
Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
