Date: Mon, 29 Nov 1999 20:17:24 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] rbtrees [was Re: AVL trees vs. Red-Black trees]
In-Reply-To: <3842D179.7FBD6A69@colorfullife.com>
Message-ID: <Pine.LNX.4.10.9911292004450.6248-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Oliver Xymoron <oxymoron@waste.org>, Kevin O'Connor <koconnor@cse.Buffalo.EDU>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Marc Lehmann <pcg@opengroup.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 1999, Manfred Spraul wrote:

>What about something similar to the "end_request()" implementation?

Personally I don't cosider that very nicer. Also look at what I am doing
in the insert, my insert also does a query, you may also do differnet
things.

But if you think it worth, I can implement that of course.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
