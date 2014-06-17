Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDDC6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 18:38:20 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id m1so48043oag.7
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 15:38:20 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id s3si16026obd.77.2014.06.17.15.38.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 15:38:20 -0700 (PDT)
From: Waiman Long <Waiman.Long@hp.com>
Subject: [PATCH v2 0/2] mm, thp: two THP splitting performance fixes
Date: Tue, 17 Jun 2014 18:37:57 -0400
Message-Id: <1403044679-9993-1-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>, Waiman Long <Waiman.Long@hp.com>

v1->v2:
 - Add a second patch to replace smp_mb() by smp_mb__after_atomic().
 - Add performance data to the first patch

This mini-series contains 2 minor changes to the transparent huge
page splitting code to split its performance, particularly for the
x86 architecture.

Waiman Long (2):
  mm, thp: move invariant bug check out of loop in
    __split_huge_page_map
  mm, thp: replace smp_mb after atomic_add by smp_mb__after_atomic

 mm/huge_memory.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
