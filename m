Date: Fri, 13 Aug 1999 18:53:45 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Strange  memory allocation error in 2.2.11
In-Reply-To: <Pine.LNX.4.10.9908131320000.4925-100000@chris.atenasio.net>
Message-ID: <Pine.LNX.3.96.990813185246.725A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Atenasio <chrisa@flashcom.net>
Cc: Linux-MM@kvack.org, Roman Levenstein <romix@geocities.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Aug 1999, Chris Atenasio wrote:

> I will comment that something is definately up with MM in 2.2.11.
> Although no one else I've asked had this problem, my 2.2.11 almost seems
> to be unable to deallocate memory, and hangs after a few minutes when
> all is used up.

First things first, get Dave's fix for the tcp memory leak (should be in
2.2.12pre3).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
