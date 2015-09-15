Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3D76B0257
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:08:08 -0400 (EDT)
Received: by lagj9 with SMTP id j9so109898986lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:07 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id ku10si13874195lac.18.2015.09.15.07.08.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:08:07 -0700 (PDT)
Received: by lbbvu2 with SMTP id vu2so13614727lbb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:06 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 00/10] Use offset_in_page() macro
Date: Tue, 15 Sep 2015 20:07:08 +0600
Message-Id: <1442326028-7088-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

This patchset does not provide functional changes, but just replaces
(addr & ~PAGE_MASK) expression with already defined offset_in_page()
macro from the <linux/mm.h>.

Alexander Kuleshov (10):
  mm/msync: Use offset_in_page macro
  mm/nommu: Use offset_in_page macro
  mm/mincore: Use offset_in_page macro
  mm/early_ioremap: Use offset_in_page macro
  mm/percpu: Use offset_in_page macro
  mm/util: Use offset_in_page macro
  mm/mlock: Use offset_in_page macro
  mm/vmalloc: Use offset_in_page macro
  mm/mmap: Use offset_in_page macro
  mm/mremap: Use offset_in_page macro

 mm/early_ioremap.c |  6 +++---
 mm/mincore.c       |  2 +-
 mm/mlock.c         |  6 +++---
 mm/mmap.c          | 12 ++++++------
 mm/mremap.c        | 12 ++++++------
 mm/msync.c         |  2 +-
 mm/nommu.c         |  8 ++++----
 mm/percpu.c        | 10 +++++-----
 mm/util.c          |  2 +-
 mm/vmalloc.c       | 12 ++++++------
 10 files changed, 36 insertions(+), 36 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
