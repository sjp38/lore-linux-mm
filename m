Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 235DB6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:52:37 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so115895295obd.3
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:52:37 -0800 (PST)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id a7si9134130oih.138.2015.11.15.22.52.35
        for <linux-mm@kvack.org>;
        Sun, 15 Nov 2015 22:52:36 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 0/7] some small improvement
Date: Mon, 16 Nov 2015 14:51:19 +0800
Message-Id: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patchset only performs some small improvement to mm. First, make
several functions return bool to improve readability, and then remove
unused is_unevictable_lru function and refactor memmap_valid_within
for simplicity.

No functional change.

Yaowei Bai (7):
  ipc/shm: is_file_shm_hugepages can be boolean
  mm/hugetlb: is_file_hugepages can be boolean
  mm/memblock: memblock_is_memory/reserved can be boolean
  mm/vmscan: page_is_file_cache can be boolean
  mm/lru: remove unused is_unevictable_lru function
  mm/gfp: make gfp_zonelist return directly and bool
  mm/mmzone: refactor memmap_valid_within

 include/linux/gfp.h       |  7 ++-----
 include/linux/hugetlb.h   | 10 ++++------
 include/linux/memblock.h  |  4 ++--
 include/linux/mm_inline.h |  6 +++---
 include/linux/mmzone.h    | 11 +++--------
 include/linux/shm.h       |  6 +++---
 ipc/shm.c                 |  2 +-
 mm/memblock.c             |  4 ++--
 mm/mmzone.c               | 10 ++--------
 9 files changed, 22 insertions(+), 38 deletions(-)

-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
