Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA18425
	for <linux-mm@kvack.org>; Fri, 9 Apr 1999 06:44:27 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14093.55795.868790.820299@dukat.scot.redhat.com>
Date: Fri, 9 Apr 1999 11:44:03 +0100 (BST)
Subject: Re: [PFC]: hash instrumentation
In-Reply-To: <Pine.BSF.4.03.9904081311320.1995-100000@funky.monkey.org>
References: <Pine.LNX.4.05.9904080015570.7123-100000@laser.random>
	<Pine.BSF.4.03.9904081311320.1995-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 8 Apr 1999 13:22:25 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> i'm discovering that a 13 bit hash mitigates the spikey size distribution
> in the page hash *better* than the +offset change.  although i've been
> able to push the system into swap, i still haven't seen any degenerate
> hash behavior that's as bad as the buffer cache's hash function.

Pushing it into swap is not sufficient: to trigger the swap cache you
need to be actively using data which has previously been swapped out,
which requires dirtying the pages, swapping them out and then touching
them again for read access.  In that special case, when the
newly-swapped-back-in page still matches the copy on disk, the swap
cache mechanism keeps both the in-memory and on-disk copies linked to
each other.

> i'll have more as i test this further.

Don't forget that you can use the "mem=*m" option at boot time to run
in a reduced memory configuration.  That might make it a bit easier
for you to trigger this stuff. :)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
