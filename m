Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EB84E6B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 06:46:08 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so129123009pad.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 03:46:08 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wp3si11801820pab.160.2015.09.26.03.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 03:46:07 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 0/5] memcg: charge page tables (x86) and pipe buffers
Date: Sat, 26 Sep 2015 13:45:52 +0300
Message-ID: <cover.1443262808.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

There are at least two object types left that can be allocated by an
unprivileged process and go uncharged to memcg - pipe buffers and page
tables. This patch set tries to make them accounted.

Comments are welcome.

Thanks,

Vladimir Davydov (5):
  mm: uncharge kmem pages from generic free_page path
  fs: charge pipe buffers to memcg
  memcg: teach uncharge_list to uncharge kmem pages
  mm: add __get_free_kmem_pages helper
  x86: charge page table pages to memcg

 arch/x86/include/asm/pgalloc.h |  5 +++--
 arch/x86/mm/pgtable.c          |  8 ++++----
 fs/pipe.c                      |  2 +-
 include/linux/gfp.h            |  4 +---
 include/linux/page-flags.h     | 22 ++++++++++++++++++++++
 kernel/fork.c                  |  2 +-
 mm/memcontrol.c                | 21 ++++++++++++++-------
 mm/page_alloc.c                | 38 ++++++++++++++++++++------------------
 mm/slub.c                      |  2 +-
 9 files changed, 67 insertions(+), 37 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
