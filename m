Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA00201
	for <linux-mm@kvack.org>; Tue, 7 Jul 1998 11:12:28 -0400
Date: Tue, 7 Jul 1998 13:35:46 +0100
Message-Id: <199807071235.NAA00941@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <m1vhpb2j9d.fsf@flinx.npwt.net>
References: <Pine.LNX.3.96.980705131034.327C-100000@dragon.bogus>
	<Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
	<199807061024.LAA00796@dax.dcs.ed.ac.uk>
	<m1vhpb2j9d.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On 06 Jul 1998 08:37:02 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

> The use of touch_page and age_page appear to be the most likely
> canidates for the page cache being more persistent than it used to
> be.

Yes., very much so.

> If I'm not mistaken shrink_mmap must be called more often now to
> remove a given page.

Indeed.  Three things I think we need to do are to lower the age
ceiling for the page cache pages; perform page allocations for the
page cache with a GFP_CACHE flag which forces us to look for other
cache pages first in try_to_free_page; and try to eliminate several
pages at a time from the page cache when we can.  (There's no point in
keeping only half the pages from a closed, sequentially accessed file
in cache.)

The first two of these are definitely small enough and clean enough
changes to be appropriate for 2.1.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
