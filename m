Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19C3E6B0253
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 14:20:20 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r141so185084wmg.4
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 11:20:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f87si26195302wmh.24.2017.02.02.11.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 11:20:18 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/7] mm: vmscan: fix kswapd writeback regression v2
Date: Thu,  2 Feb 2017 14:19:50 -0500
Message-Id: <20170202191957.22872-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

here are some minor updates to the series. It's nothing functional,
just code comments and updates to the changelogs from the mailing list
discussions. Since we don't have a good delta system for changelogs
I'm resending the entire thing as a drop-in replacement for -mm.

These are the changes:

1. mm: vmscan: scan dirty pages even in laptop mode

   Mel tested the entire series, not just one patch. Move his test
   conclusions from 'mm: vmscan: remove old flusher wakeup from direct
   reclaim' into the series header in patch 1. Also, reflect the fact
   that these test results are indeed Mel's, not mine.

2. mm: vmscan: kick flushers when we encounter dirty pages on the LRU

   Mention the trade-off between flush-the-world/flush-the-scanwindow
   type wakeups in the changelog, as per the mailing list discussion.

3. mm: vmscan: move dirty pages out of the way until they're flushed

   Correct the last paragraph in the changelog. We're not activating
   dirty/writeback pages after they have rotated twice; they are being
   activated straight away to get them out of the reclaimer's face.
   This was a vestige from an earlier version of the patch.

4. mm: vmscan: move dirty pages out of the way until they're flushed fix

   Code comment fixlet to explain why we activate dirty/writeback pages.

Thanks!

 include/linux/mm_inline.h        |  7 ++++
 include/linux/mmzone.h           |  2 -
 include/linux/writeback.h        |  2 +-
 include/trace/events/writeback.h |  2 +-
 mm/swap.c                        |  9 +++--
 mm/vmscan.c                      | 77 ++++++++++++++++++--------------------
 6 files changed, 50 insertions(+), 49 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
