Subject: Re: [Patch] shm cleanups
References: <Pine.LNX.4.10.9911042319530.8880-100000@chiara.csoma.elte.hu> <m3yacd23sj.fsf@alpha.random> <qwwpuxp9kvb.fsf@sap.com>
From: Andrea Arcangeli <andrea@suse.de>
Date: 05 Nov 1999 14:18:03 +0100
In-Reply-To: Christoph Rohland's message of "05 Nov 1999 13:35:36 +0100"
Message-ID: <m3wvrxcc1g.fsf@alpha.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Ingo Molnar <mingo@chiara.csoma.elte.hu>, Rik van Riel <riel@nl.linux.org>, MM mailing list <linux-mm@kvack.org>, woodman@missioncriticallinux.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Christoph Rohland <hans-christoph.rohland@sap.com> writes:

>         if (!(page_map = prepare_highmem_swapout(page_map)))
> -               goto check_table;
> +               goto failed;

This fragment isn't correct. You may fail too early and so you may get
a task killed due OOM even if you still have lots of regular pages
queued in a shm segment.

-- 
Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
