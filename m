Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA10516
	for <linux-mm@kvack.org>; Sat, 16 Jan 1999 08:22:23 -0500
Date: Sat, 16 Jan 1999 14:22:10 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <19990116115459.A7544@hexagon>
Message-ID: <Pine.LNX.3.96.990116141939.701A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nimrod Zimerman <zimerman@deskmail.com>
Cc: Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jan 1999, Nimrod Zimerman wrote:

> Personally, I don't like the way the pager works. It is too magical. Change
> 'priority', and it might work better. Why? Because. I much preferred the old
> approach, of being able to simply tell the cache (and buffers, though I
> don't see this unless I explicitly try to enlarge it) to *never*, *ever* grow
> over some arbitrary limit. This is far better for smaller machines, at
> least as far as I can currently see.

Setting an high limit for the cache when we are low memory is easy doable.
Comments from other mm guys?

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
