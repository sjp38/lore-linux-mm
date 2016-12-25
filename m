Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4922A6B0038
	for <linux-mm@kvack.org>; Sat, 24 Dec 2016 22:00:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so642892151pgi.2
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 19:00:43 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id a96si39013893pli.220.2016.12.24.19.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Dec 2016 19:00:42 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id b1so5268219pgc.1
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 19:00:42 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 0/2] PageWaiters again
Date: Sun, 25 Dec 2016 13:00:28 +1000
Message-Id: <20161225030030.23219-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

I cleaned up the changelog a bit and made a few tweaks to patch 1 as
described in my reply to Hugh. Resending with SOBs.

Thanks,
Nick

Nicholas Piggin (2):
  mm: Use owner_priv bit for PageSwapCache, valid when PageSwapBacked
  mm: add PageWaiters indicating tasks are waiting for a page bit

 include/linux/mm.h             |   2 +
 include/linux/page-flags.h     |  33 ++++++--
 include/linux/pagemap.h        |  23 +++---
 include/linux/writeback.h      |   1 -
 include/trace/events/mmflags.h |   2 +-
 init/main.c                    |   3 +-
 mm/filemap.c                   | 181 +++++++++++++++++++++++++++++++++--------
 mm/internal.h                  |   2 +
 mm/memory-failure.c            |   4 +-
 mm/migrate.c                   |  14 ++--
 mm/swap.c                      |   2 +
 11 files changed, 199 insertions(+), 68 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
