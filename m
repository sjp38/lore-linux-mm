Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 925786B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 03:53:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p188so2495195pfp.1
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 00:53:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor2004243pgo.359.2018.02.20.00.53.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 00:53:30 -0800 (PST)
From: minchan@kernel.org
Subject: [PATCH RESEND 0/2] swap readahead clean up
Date: Tue, 20 Feb 2018 17:52:47 +0900
Message-Id: <20180220085249.151400-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>

From: Minchan Kim <minchan@kernel.org>

This patchset cleans up recent added vma-based readahead code via
unifying cluster-based readahead.

Resent based on mmotm-2018-02-06-16-41.

Minchan Kim (2):
  mm: swap: clean up swap readahead
  mm: swap: unify cluster-based and vma-based swap readahead

 include/linux/swap.h |  38 +++---------
 mm/memory.c          |  33 +++--------
 mm/shmem.c           |   5 +-
 mm/swap_state.c      | 137 +++++++++++++++++++++++++++----------------
 4 files changed, 105 insertions(+), 108 deletions(-)

-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
