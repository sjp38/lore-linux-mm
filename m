Message-ID: <4020BDCB.8030707@cyberone.com.au>
Date: Wed, 04 Feb 2004 20:39:23 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [PATCH 0/5] mm improvements
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patches against 2.6.2-rc3-mm1.
Please test / review / comment.

1/5: vm-no-rss-limit.patch
     Remove broken RSS limiting. Simple problem, Rik is onto it.

2/5: vm-dont-rotate-active-list.patch
     Nikita's patch to keep more page ordering info in the active list.
     Also should improve system time due to less useless scanning
     Helps swapping loads significantly.

3/5: vm-lru-info.patch
     Keep more referenced info in the active list. Should also improve
     system time in some cases. Helps swapping loads significantly.

4/5: vm-fix-shrink-zone.patch
     Most significant part of this patch changes active / inactive
     balancing. This improves non swapping kbuild by a few %. Helps
     swapping significantly.

     It also contains a number of other small fixes which have little
     measurable impact on kbuild.

5/5: vm-tune-throttle.patch
     Try to allocate a bit harder before giving up / throttling on
     writeout.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
