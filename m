Received: from post.mail.nl.demon.net (post-10.mail.nl.demon.net [194.159.73.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA27543
	for <linux-mm@kvack.org>; Wed, 19 May 1999 15:04:15 -0400
Date: Wed, 19 May 1999 20:46:51 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Swapping out old pages
In-Reply-To: <001501bea117$c0a2d850$2b01c80a@pc-kvo.antwerp.seagha.com>
Message-ID: <Pine.LNX.4.03.9905192043200.275-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Karl Vogel <kvo@mail.seagha.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 May 1999, Karl Vogel wrote:

> - why does the swap out algorithm select the task with the largest
> RSS to free pages. If I'm not mistaken, the age of a page isn't
> considered?! Why is that? Am I overlooking something?

You're overlooking the fact that p->swap_cnt is only
recalculated when all processes have been scanned.

A new sweep starts at the process with the largest
swap_cnt -- but all processes are scanned eventually.

> - wouldn't it be beneficial if there is a parameter that allows
> you to specify that after a certain age, a page is swapped out to
> make room for the buffer cache.

The system already does that, and has been doing so
rather agressively since 2.1.89...

cheers,

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
