Message-Id: <20050810200216.644997000@jumble.boston.redhat.com>
Date: Wed, 10 Aug 2005 16:02:16 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH/RFT 0/5] CLOCK-Pro page replacement
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here it is, the result of many months of thinking and a few
all-nighters.  CLOCK-Pro page replacement is an algorithm
designed to keep those pages on the active list that were
referenced "most frequently, recently", ie. the pages that
have the smallest distance between the last two subsequent
references.

I had to make some changes to the algorithm in order to
reduce the space overhead of keeping track of non-resident
pages, as well as work in a multi-zone VM.

The algorithm still needs lots of testing, and probably tuning:
- should new anonymous pages start out on the active or
  the inactive list ?
- is this implementation of the algorithm buggy ?
- are there performance regressions ?

I have only done very rudimentary testing of the algorithm
here, and while it appears to be behaving as expected, I do
not know whether the expected behaviour is the right thing...

I think I have acted on all the feedback people have given
me on the non-resident pages patch set.

Any comments, observations, etc. are appreciated.

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
