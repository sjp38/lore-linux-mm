Date: Sun, 13 Jun 1999 08:58:47 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: process selection
In-Reply-To: <Pine.LNX.4.10.9906130313510.7016-100000@laser.random>
Message-ID: <Pine.LNX.4.03.9906130856130.534-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jun 1999, Andrea Arcangeli wrote:
> On Sat, 12 Jun 1999, Rik van Riel wrote:
> 
> >Could it be an idea to take the 'sleeping time' of each
> >process into account when selecting which process to swap
> >out?  Due to extreme lack of free time, I'm asking what
> 
> The CPUs set the "accessed" bit in hardware, and that should be
> enough to do proper aging. If setiathome is all in RAM it means it
> gets touched more fast than netscape.

Setiathome had been stopped (by loadwatch) for over an hour.
This means that _everything_ else in the system could have
been touched more often.

Unfortunately, the kernel was still busy shrinking the page
cache and the swapout counter was still with X and later with
Netscape -- it didn't advance fast enough to get to setiathome,
yet writing out my mailbox took so much disk activity in the
limited buffer space that my mp3s began skipping.


Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
