Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFC06B02B9
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 03:04:04 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rf5so3795141pab.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 00:04:04 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id gt2si1106392pac.80.2016.11.02.00.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 00:04:03 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i88so917561pfk.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 00:04:03 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC][PATCH 0/2] optimise unlock_page / end_page_writeback
Date: Wed,  2 Nov 2016 18:03:44 +1100
Message-Id: <20161102070346.12489-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

Hi,

There doesn't seem to be much more discussion about this, so let's
kick it along a bit. I tried to reclaim a page flag because I can't
bring myself to ifdef it to 64-bit only, but otherwise the patches
don't depend on each other at all.

Thanks,
Nick

Nicholas Piggin (2):
  mm: Use owner_priv bit for PageSwapCache, valid when PageSwapBacked
  mm: add PageWaiters bit to indicate waitqueue should be checked

 include/linux/page-flags.h     |  14 +++-
 include/linux/pagemap.h        |  23 +++---
 include/trace/events/mmflags.h |   2 +-
 mm/filemap.c                   | 157 ++++++++++++++++++++++++++++++++---------
 mm/swap.c                      |   2 +
 5 files changed, 148 insertions(+), 50 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
