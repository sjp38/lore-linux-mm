Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3AC76B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:44:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b6so8205249pff.18
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:44:00 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o11si422642pgd.473.2017.10.20.01.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 01:43:59 -0700 (PDT)
From: changbin.du@intel.com
Subject: [PATCH v2 0/2] mm, thp: introduce dedicated transparent huge page allocation interfaces
Date: Fri, 20 Oct 2017 16:36:26 +0800
Message-Id: <1508488588-23539-1-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, khandual@linux.vnet.ibm.com, kirill@shutemov.name, Changbin Du <changbin.du@intel.com>

From: Changbin Du <changbin.du@intel.com>

The first one introduce new interfaces, the second one kills naming confusion.
The aim is to simplify transparent huge page allocation and remove duplicated
code.

V2:
  - Coding improvment.
  - Fix build error if thp is disabled.

Changbin Du (2):
  mm, thp: introduce dedicated transparent huge page allocation
    interfaces
  mm: rename page dtor functions to {compound,huge,transhuge}_page__dtor

 Documentation/vm/hugetlbfs_reserv.txt |  4 +--
 include/linux/gfp.h                   |  4 ---
 include/linux/huge_mm.h               | 20 ++++++++++++--
 include/linux/hugetlb.h               |  2 +-
 include/linux/migrate.h               | 14 ++++------
 include/linux/mm.h                    |  8 +++---
 mm/huge_memory.c                      | 52 +++++++++++++++++++++++++++++------
 mm/hugetlb.c                          | 14 +++++-----
 mm/khugepaged.c                       | 11 ++------
 mm/mempolicy.c                        | 14 ++--------
 mm/migrate.c                          | 14 +++-------
 mm/page_alloc.c                       | 10 +++----
 mm/shmem.c                            |  6 ++--
 mm/swap.c                             |  2 +-
 mm/userfaultfd.c                      |  2 +-
 15 files changed, 97 insertions(+), 80 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
