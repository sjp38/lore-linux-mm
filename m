Date: Sun, 4 Jul 1999 16:35:41 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] fix for OOM deadlock in swap_in (2.2.10) [Re: [test
 program] for OOM situations ]
In-Reply-To: <Pine.LNX.4.03.9907041142420.216-100000@mirkwood.nl.linux.org>
Message-ID: <Pine.LNX.4.10.9907041624010.2274-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Bernd Kaindl <bk@suse.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, kernel@suse.de, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Jul 1999, Rik van Riel wrote:

>I'm curious why you haven't yet included my process
>selection algoritm. I know it can select a blocked
>or otherwise unkillable process the way the code is
>in right now, but a workaround for that can be made
>in about 5 minutes.

Yes, we can try killing the "best" task some time and cache it's task
struct, if the task won't go away shortly (say in 5 sec) then we can
revert to the safe choice (we always have) of killing the current task
that will sure return to userspace soon.

I didn't merged your selection algorithm in the patch I posted, only
because I tried to produce a patch with only bugfix and simple things
included to give it a way to go into 2.2.11. The only object of the patch
is to avoid linux to deadlock and avoid init to be screwed up. You can
still avoid the admin to login on the console with an evil script, but the
kernel will continue running fine (no deadlock). That's what 2.2.x should
do just now.

>The "show me the code" attitude doesn't seem to fit
>me now, unfortunately. I'm still busy moving house
>and I have to be a good python programmer by tomorrow.
>Having never seen much python but with the book in
>front of me :)

Don't worry, a friend of mine said me that phyton is very easy to learn
:). I can't talk of myself since I never used phyton (I'll try it soon
though).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
