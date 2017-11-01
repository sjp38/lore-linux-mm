Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD466B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 03:15:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l23so1706533pgc.10
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 00:15:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u185si3765672pgb.101.2017.11.01.00.15.23
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 00:15:23 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 0/2] swap readahead clean up
Date: Wed,  1 Nov 2017 16:15:18 +0900
Message-Id: <1509520520-32367-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

This patchset cleans up recent added vma-based readahead code via
unifying cluster-based readahead.

* From v1
  * renamed swap_cluster_readahead - Huang
  * remove unnecessary extern declaration - Huang
  * add description for swapin_readahead - Huang

Minchan Kim (2):
  mm:swap: clean up swap readahead
  mm:swap: unify cluster-based and vma-based swap readahead

 include/linux/swap.h |  38 +++-----------
 mm/memory.c          |  24 +++------
 mm/shmem.c           |   5 +-
 mm/swap_state.c      | 137 ++++++++++++++++++++++++++++++++-------------------
 4 files changed, 103 insertions(+), 101 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
