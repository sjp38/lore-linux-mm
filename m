Date: Tue, 30 Nov 1999 15:14:07 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] rbtrees [was Re: AVL trees vs. Red-Black trees]
In-Reply-To: <19991130002755.A22847@armstrong.cse.Buffalo.EDU>
Message-ID: <Pine.LNX.4.10.9911301506300.359-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kevin O'Connor <koconnor@cse.Buffalo.EDU>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Oliver Xymoron <oxymoron@waste.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Marc Lehmann <pcg@opengroup.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 1999, Kevin O'Connor wrote:

>[..]  I've got inserts working, but
>removes are becoming a myriad of special cases..

removes are trivial with rbtrees as you never need to compare nodes. All
the rebalancing is done in function of the node color (that is a private
information of each node). The same is true also for the
insert-rebalancing, but to do an insert you must first browse the tree to
do a normal ordered O(log(n)) insert before calling the rebalance (thus a
compare semantic on elements is necessary for the insert operation to
work).

Andrea




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
