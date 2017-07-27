Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60FFD6B02B4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:07:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o82so4129408pfj.11
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:07:00 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id g9si11464358pli.273.2017.07.27.05.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:06:59 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id d193so20332228pgc.2
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:06:59 -0700 (PDT)
From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 0/5] constify mm attribute_group structures.
Date: Thu, 27 Jul 2017 17:36:06 +0530
Message-Id: <1501157167-3706-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, aarcange@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work with
const attribute_group. So mark the non-const structs as const.

Arvind Yadav (5):
  [PATCH 1/5] mm: ksm: constify attribute_group structures.
  [PATCH 2/5] mm: slub: constify attribute_group structures.
  [PATCH 3/5] mm: page_idle: constify attribute_group structures.
  [PATCH 4/5] mm: huge_memory: constify attribute_group structures.
  [PATCH 5/5] mm: hugetlb: constify attribute_group structures.

 mm/huge_memory.c | 2 +-
 mm/hugetlb.c     | 6 +++---
 mm/ksm.c         | 2 +-
 mm/page_idle.c   | 2 +-
 mm/slub.c        | 2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
