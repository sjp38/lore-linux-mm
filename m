Date: Sun, 19 Aug 2001 07:11:48 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819071148.B8700@athlon.random>
References: <20010819012713.N1719@athlon.random> <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com> <20010819023548.P1719@athlon.random> <20010819025314.R1719@athlon.random> <20010819032544.X1719@athlon.random> <20010819034050.Z1719@athlon.random> <20010819045906.E1719@athlon.random> <20010819055311.A8700@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010819055311.A8700@athlon.random>; from andrea@suse.de on Sun, Aug 19, 2001 at 05:53:11AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 19, 2001 at 05:53:11AM +0200, Andrea Arcangeli wrote:
> just need to do a second lookup after upgrading the lock because we
> don't have a primitive to upgrade the lock from "read" to "write"

I attempted to write such a primitive but it's impossible without a fail
path (think two readers trying to upgrade the lock at the same time, it
either deadlocks or one of the two will have to fail the atomic
upgrade and accept that something has changed under it), so it could
only improve performance saving a lookup sometime in case we are the
only readers out there, but we would still need to implement the ugly
slow path case (and avoiding the ugliness of such code was the only
reason I attempted to write such a primitive so...)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
