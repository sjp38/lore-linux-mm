Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA24398
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 07:07:51 -0400
Date: Mon, 6 Jul 1998 11:38:10 +0100
Message-Id: <199807061038.LAA00803@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705212422.2416D-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.980705202128.12985B-100000@dragon.bogus>
	<Pine.LNX.3.96.980705212422.2416D-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Rik,

On Sun, 5 Jul 1998 21:31:56 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> A few months ago someone (who?) posted a patch that modified
> kswapd's internals to only unmap clean pages when told to.

> If I can find the patch, I'll integrate it and let kswapd
> only swap clean pages when:
> - page_cache_size * 100 > num_physpages * page_cache.borrow_percent
> or
> - (buffer_mem >> PAGE_SHIFT) * 100 > num_physpages * buffermem.borrow_percent

I'm not sure what that is supposed to achieve, and I'm not sure how well
we expect such tinkering to work uniformly on 8MB and 512MB machines.
Unmapping is not an issue with respect to cache sizes.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
