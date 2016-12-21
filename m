Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20FCC6B03AE
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:20:15 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so320690768pfb.6
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:20:15 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 61si27081498pla.14.2016.12.21.07.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 07:20:14 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 127so1086681pfg.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:20:13 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 0/2] respin of PageWaiters patch
Date: Thu, 22 Dec 2016 01:19:49 +1000
Message-Id: <20161221151951.16396-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>
Cc: Nicholas Piggin <npiggin@gmail.com>

Seeing as Mel said he would test it (and maybe Dave could as well), I
will post my patches again. There was a couple of page flags bugs pointed
out last time, which should be fixed.

Thanks,
Nick




Nicholas Piggin (2):
  mm: Use owner_priv bit for PageSwapCache, valid when PageSwapBacked
  mm: add PageWaiters bit to indicate waitqueue should be checked

 include/linux/mm.h             |   2 +
 include/linux/page-flags.h     |  33 ++++++--
 include/linux/pagemap.h        |  23 +++---
 include/linux/writeback.h      |   1 -
 include/trace/events/mmflags.h |   2 +-
 init/main.c                    |   3 +-
 mm/filemap.c                   | 180 +++++++++++++++++++++++++++++++++--------
 mm/internal.h                  |   2 +
 mm/swap.c                      |   2 +
 9 files changed, 189 insertions(+), 59 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
