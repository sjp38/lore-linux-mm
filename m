Received: from fred.muc.de (noidentity@ns2008.munich.netsurf.de [195.180.232.8])
	by kvack.org (8.8.7/8.8.7) with SMTP id JAA01310
	for <linux-mm@kvack.org>; Mon, 26 Apr 1999 09:47:22 -0400
Message-ID: <19990426154524.A749@kali.munich.netsurf.de>
Date: Mon, 26 Apr 1999 15:45:24 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: 2.2.6_andrea2.bz2
References: <Pine.LNX.4.05.9904252047530.7477-100000@laser.random> <m1yajfg61n.fsf@flinx.ccr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1yajfg61n.fsf@flinx.ccr.net>; from Eric W. Biederman on Mon, Apr 26, 1999 at 10:05:56AM +0200
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Andrea Arcangeli <andrea@e-mind.com>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 26, 1999 at 10:05:56AM +0200, Eric W. Biederman wrote:
> >>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:
> 
> >>> o	update_shared_mappings (will greatly improve performances while
> >>> writing from many task to the same shared memory).
> >> 
> >> do you have performance numbers on this?
> 
> AA> The performance optimization can be huge.
> 
> AA> The reason this my code is not in the kernel is not because it's buggy but
> AA> simple because there are plans for 2.3.x (no-way for 2.2.x) to allow the
> AA> file cache to be dirty (to cache also writes and not only read in the page
> AA> cache).
> 
> Andrea.  The plan (at least my plan) is not to have 2 layers of buffers.
> Instead it is to do all of the caching (except for perhaps superblocks, and their
> kin in the page cache).  brw_page will be used for both reads and writes, with
> anonymouse buffer heads (at least for a start).

Stupid question: do you plan to cache fs metadata in the page cache too? 
If yes, it is rather wasteful to use a 4K page for the usually block sized
directories and other fs data like indirect blocks. How do you plan to 
address this problem?


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
