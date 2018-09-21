Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 065118E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:40:08 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 77-v6so1905871pgg.0
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:40:07 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w64-v6si8510159pgb.476.2018.09.21.15.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:40:06 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 0/6] mm: faster get user pages
Date: Fri, 21 Sep 2018 16:39:50 -0600
Message-Id: <20180921223956.3485-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Changes since v2:

  Combine only the output parameters in a struct that need tracking,
  and squash to just one final kernel patch.

  Fixed compile bugs for all configs

Keith Busch (6):
  mm/gup_benchmark: Time put_page
  mm/gup_benchmark: Add additional pinning methods
  tools/gup_benchmark: Fix 'write' flag usage
  tools/gup_benchmark: Allow user specified file
  tools/gup_benchmark: Add parameter for hugetlb
  mm/gup: Cache dev_pagemap while pinning pages

 include/linux/huge_mm.h                    |  8 +--
 include/linux/mm.h                         | 19 ++++++-
 mm/gup.c                                   | 90 +++++++++++++++++-------------
 mm/gup_benchmark.c                         | 36 ++++++++++--
 mm/huge_memory.c                           | 38 ++++++-------
 mm/nommu.c                                 |  4 +-
 tools/testing/selftests/vm/gup_benchmark.c | 40 +++++++++++--
 7 files changed, 154 insertions(+), 81 deletions(-)

-- 
2.14.4
