Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31183
	for <linux-mm@kvack.org>; Mon, 27 Jul 1998 15:44:44 -0400
Date: Mon, 27 Jul 1998 11:51:50 +0100
Message-Id: <199807271051.LAA00702@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Page cache ageing: yae or nae?
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

In following the latest round of performance reports from Zlatzo
Calusic, it's clear we still need to think a bit about the
aggressiveness of the page cache.  It's not a maximum age issue: _any_
scheme which fails to clear a page from the page cache in one round of
ageing will suffer from his problem with large copies.

Could you let me know just what benchmarks you were running when you
added the first page ageing code to see a speedup?  I think we need to
look carefully at the properties of the ageing scheme and the simple
clock algorithm we had before to see where the best compromise is.  It
may be that we can get away with something simple like just reducing
the initial page age for the page cache, but I'd like to make sure
that the readahead problems you alluded to are not brought back by any
other changes we make to the mechanism.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
