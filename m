Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B16C6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 01:29:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b85so1243638pfj.22
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 22:29:02 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f15si3758289pfd.511.2017.10.31.22.29.00
        for <linux-mm@kvack.org>;
        Tue, 31 Oct 2017 22:29:01 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/2] swap readahead clean up
Date: Wed,  1 Nov 2017 14:28:21 +0900
Message-Id: <1509514103-17550-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

This patchset cleans up recent added vma-based readahead code via
unifying cluster-based readahead.

Minchan Kim (2):
  mm:swap: clean up swap readahead
  mm:swap: unify cluster-based and vma-based swap readahead

 include/linux/swap.h |  32 +++++++--------
 mm/memory.c          |  24 +++--------
 mm/shmem.c           |   5 ++-
 mm/swap_state.c      | 110 +++++++++++++++++++++++++++++----------------------
 4 files changed, 87 insertions(+), 84 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
