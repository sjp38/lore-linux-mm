Message-ID: <3842D179.7FBD6A69@colorfullife.com>
Date: Mon, 29 Nov 1999 20:18:17 +0100
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [patch] rbtrees [was Re: AVL trees vs. Red-Black trees]
References: <Pine.LNX.4.10.9911291649470.5133-100000@alpha.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Oliver Xymoron <oxymoron@waste.org>, Kevin O'Connor <koconnor@cse.Buffalo.EDU>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Marc Lehmann <pcg@opengroup.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> +  To use rbtrees you'll have to implement your own insert and search cores.
> +  This will avoid us to use callbacks and to drop drammatically performances.
> +  I know it's not the cleaner way,  but in C (not in C++) to get
> +  performances and genericity...
> +
> +  Some example of insert and search follows here. The search is a plain
> +  normal search over an ordered tree. The insert instead must be implemented
> +  int two steps: as first thing the code must insert the element in
> +  order as a red leaf in the tree, then the support library function
> +  rb_insert_color() must be called. Such function will do the
> +  not trivial work to rebalance the rbtree if necessary.

What about something similar to the "end_request()" implementation?

ie you #define a name and the (inline) compare function, then you
#include <rbtree.h>. <rbtree.h> creates all functions that you need.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
