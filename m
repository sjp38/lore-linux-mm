Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA32583
	for <linux-mm@kvack.org>; Tue, 1 Jun 1999 12:06:46 -0400
Date: Tue, 1 Jun 1999 16:23:59 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <14163.8950.319558.793463@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9906011606220.770-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 1999, Stephen C. Tweedie wrote:

>Cute!  When, oh when, are you going to start releasing these things as

Happy to hear that :).

>separate patches which I can look at?  This is one simple optimisation

ASAP. Some second ago I started playing with the proggy that lockups the
machine recursing on the stack (that I am been able to reproduce here too
under some condition). When I'll understand which is the problem that
causes the lockup, then theorically I could just start the merging stage.
If you are interested I can CC the separate patches also to you.

>that I'd really like to see in 2.3 asap.

Linus asked me to wait Ingo's page cache code to be included in 2.3.x
before starting sending him patches. I am a bit worried starting
exctracting separate patches _now_, because if Ingo's page cache code will
break my patches, then I'll have to generate new patches tomorrow... So I
would like to have hints from Ingo. (note: I am fine also waiting a bit
more of time, just know that from my part I would just did the merging)

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
