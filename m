Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32F1C6B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:24:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v190so14081890pfb.5
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 123si679923pfg.257.2017.03.14.22.24.57
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:58 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 00/10] make try_to_unmap simple
Date: Wed, 15 Mar 2017 14:24:43 +0900
Message-ID: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

Currently, try_to_unmap returns various return value(SWAP_SUCCESS,
SWAP_FAIL, SWAP_AGAIN, SWAP_DIRTY and SWAP_MLOCK). When I look into
that, it's unncessary complicated so this patch aims for cleaning
it up. Change ttu to boolean function so we can remove SWAP_AGAIN,
SWAP_DIRTY, SWAP_MLOCK.

* from v1
  * add some acked-by
  * add description about rmap_one's return - Andrew

* from RFC
- http://lkml.kernel.org/r/1488436765-32350-1-git-send-email-minchan@kernel.org
  * Remove RFC tag
  * add acked-by to some patches
  * some of minor fixes
  * based on mmotm-2017-03-09-16-19.


Minchan Kim (10):
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
 include/linux/rmap.h | 25 ++++++--------
 mm/huge_memory.c     |  6 ++--
 mm/ksm.c             | 16 ++++-----
 mm/memory-failure.c  | 26 +++++++-------
 mm/migrate.c         |  4 +--
 mm/mlock.c           |  6 ++--
 mm/page_idle.c       |  4 +--
 mm/rmap.c            | 98 ++++++++++++++++++++--------------------------------
 mm/vmscan.c          | 32 +++++------------
 10 files changed, 85 insertions(+), 137 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
