Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA2A280956
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 20:36:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w189so271234170pfb.4
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 17:36:01 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p19si9838156pgk.165.2017.03.12.17.35.59
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 17:36:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 00/10] make try_to_unmap simple
Date: Mon, 13 Mar 2017 09:35:43 +0900
Message-ID: <1489365353-28205-1-git-send-email-minchan@kernel.org>
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

 include/linux/ksm.h  |   5 ++-
 include/linux/rmap.h |  21 ++++-------
 mm/huge_memory.c     |   6 ++--
 mm/ksm.c             |  16 ++++-----
 mm/memory-failure.c  |  26 +++++++-------
 mm/migrate.c         |   4 +--
 mm/mlock.c           |   6 ++--
 mm/page_idle.c       |   4 +--
 mm/rmap.c            | 100 ++++++++++++++++++++-------------------------------
 mm/vmscan.c          |  32 +++++------------
 10 files changed, 82 insertions(+), 138 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
