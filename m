Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 091296B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b2so81621836pgc.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:30 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k15si311963pfj.185.2017.03.01.22.39.29
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:30 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 00/11] make try_to_unmap simple
Date: Thu,  2 Mar 2017 15:39:14 +0900
Message-Id: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

Currently, try_to_unmap returns various return value(SWAP_SUCCESS,
SWAP_FAIL, SWAP_AGAIN, SWAP_DIRTY and SWAP_MLOCK). When I look into
that, it's unncessary complicated so this patch aims for cleaning
it up. Change ttu to boolean function so we can remove SWAP_AGAIN,
SWAP_DIRTY, SWAP_MLOCK.

This patchset is based on v4.10-mmots-2017-02-28-17-33.

Minchan Kim (11):
  mm: use SWAP_SUCCESS instead of 0
  mm: remove unncessary ret in page_referenced
  mm: remove SWAP_DIRTY in ttu
  mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
  mm: make the try_to_munlock void function
  mm: remove SWAP_MLOCK in ttu
  mm: remove SWAP_AGAIN in ttu
  mm: make ttu's return boolean
  mm: make rmap_walk void function
  mm: make rmap_one boolean function
  mm: remove SWAP_[SUCCESS|AGAIN|FAIL]

 include/linux/ksm.h  |  5 ++-
 include/linux/rmap.h | 21 ++++--------
 mm/huge_memory.c     |  4 +--
 mm/ksm.c             | 16 ++++-----
 mm/memory-failure.c  | 22 ++++++------
 mm/migrate.c         |  4 +--
 mm/mlock.c           |  6 ++--
 mm/page_idle.c       |  4 +--
 mm/rmap.c            | 97 ++++++++++++++++++++--------------------------------
 mm/vmscan.c          | 26 +++-----------
 10 files changed, 73 insertions(+), 132 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
