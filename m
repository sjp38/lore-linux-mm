Date: Sun, 4 Jul 1999 11:48:32 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [patch] fix for OOM deadlock in swap_in (2.2.10) [Re: [test
 program] for OOM situations ]
In-Reply-To: <Pine.LNX.4.10.9907022203230.20108-100000@laser.random>
Message-ID: <Pine.LNX.4.03.9907041142420.216-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Bernd Kaindl <bk@suse.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, kernel@suse.de, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sat, 3 Jul 1999, Andrea Arcangeli wrote:

> +void oom(void)
>  {
...
> +	force_sig(SIGKILL, current);

> I would like to get some feedback about the patch. Thanks :).

I'm curious why you haven't yet included my process
selection algoritm. I know it can select a blocked
or otherwise unkillable process the way the code is
in right now, but a workaround for that can be made
in about 5 minutes.

The "show me the code" attitude doesn't seem to fit
me now, unfortunately. I'm still busy moving house
and I have to be a good python programmer by tomorrow.
Having never seen much python but with the book in
front of me :)

cheers,

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
