Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52D416B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 05:26:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v78so14218010pfk.8
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 02:26:32 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 185si4124078pfu.388.2017.10.16.02.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 02:26:31 -0700 (PDT)
From: changbin.du@intel.com
Subject: [PATCH 0/2] mm, thp: introduce dedicated transparent huge page allocation interfaces
Date: Mon, 16 Oct 2017 17:19:15 +0800
Message-Id: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Changbin Du <changbin.du@intel.com>

From: Changbin Du <changbin.du@intel.com>

The first one introduce new interfaces, the second one kills naming confusion.
The aim is to remove duplicated code and simplify transparent huge page
allocation.

Changbin Du (2):
  mm, thp: introduce dedicated transparent huge page allocation
    interfaces
  mm: rename page dtor functions to {compound,huge,transhuge}_page__dtor

 Documentation/vm/hugetlbfs_reserv.txt |  4 +--
 include/linux/gfp.h                   |  4 ---
 include/linux/huge_mm.h               | 15 ++++++++--
 include/linux/hugetlb.h               |  2 +-
 include/linux/migrate.h               | 14 ++++-----
 include/linux/mm.h                    |  8 +++---
 mm/huge_memory.c                      | 54 +++++++++++++++++++++++++++++------
 mm/hugetlb.c                          | 14 ++++-----
 mm/khugepaged.c                       | 11 ++-----
 mm/mempolicy.c                        | 10 ++-----
 mm/migrate.c                          | 12 +++-----
 mm/page_alloc.c                       | 10 +++----
 mm/shmem.c                            |  6 ++--
 mm/swap.c                             |  2 +-
 mm/userfaultfd.c                      |  2 +-
 15 files changed, 95 insertions(+), 73 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
