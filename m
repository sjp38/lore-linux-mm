Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA07906
	for <linux-mm@kvack.org>; Fri, 12 Jun 1998 01:06:11 -0400
Subject: Q: I can get kswapd to run but not swap anything...
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 12 Jun 1998 00:18:53 -0500
Message-ID: <m1zpfj42pu.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


With my shmfs code on linux-2.1.101 after untaring two kernel
source trees, on my 32M machine, kswapd eats about 20% of the cpu time
according to swap but nearly nothing is written out.  

Currently I use shrink_mmap to write out pages.  If a page has a use
count of 1 and is dirty it gets written to swap and the dirty bit
removed instead of being removed from the page cache, and shrink_mmap
returns 1.

With 2.0.32 using exactly the same approach everything works fine, and
while there is a slight performance hit for lots of writes, the system
is always quite usable.

Does anyone have a clue why my machine becomes nearly unusable with 
2.1.101 in this fashion?

I am asking this here because a) my changes are quite small and have
worked reasonably well on other kernels, and b) something else may be
able to trigger the same condition.

If it helps at all I am pretty certain that running lots of file
writes through my filesystem is a pretty good way of fragmenting
memory.

Eric
