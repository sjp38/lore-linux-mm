Received: from caffeine.ix.net.nz (caffeine.ix.net.nz [203.97.118.28])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA30229
	for <linux-mm@kvack.org>; Wed, 19 May 1999 19:29:20 -0400
Date: Thu, 20 May 1999 11:29:12 +1200
From: Chris Wedgwood <cw@ix.net.nz>
Subject: Re: Q: PAGE_CACHE_SIZE?
Message-ID: <19990520112912.A5473@caffeine.ix.net.nz>
References: <m1yaimzd82.fsf@flinx.ccr.net> <19990518170401.A3966@fred.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19990518170401.A3966@fred.muc.de>; from Andi Kleen on Tue, May 18, 1999 at 05:04:01PM +0200
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@muc.de>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I guess the main motivation comes from the ARM port, where some
> versions have PAGE_SIZE=32k.

I've often wondered if it wouldn't be a good idea to do this on Intel
boxes sometimes, especially as many machines routinely have 512MB of
ram, so we could probably get away with merge 4 pages into one and
having pseudo-16k pages.

Presumably this might/will break existing stuff though... I think
many of these could be worked around though.




-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
