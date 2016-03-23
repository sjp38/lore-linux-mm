Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 25B0D6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 22:37:39 -0400 (EDT)
Received: by mail-oi0-f45.google.com with SMTP id i17so3031377oib.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 19:37:39 -0700 (PDT)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id oz4si127620obb.99.2016.03.22.19.37.37
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 19:37:38 -0700 (PDT)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 0/5] mm: make several functions return bool
Date: Wed, 23 Mar 2016 10:26:04 +0800
Message-Id: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, baiyaowei@cmss.chinamobile.com

This series only makes several functions return bool to
improve readability, no other functional changes.

Yaowei Bai (5):
  mm/hugetlb: is_vm_hugetlb_page can be boolean
  mm/memory_hotplug: is_mem_section_removable can be boolean
  mm/vmalloc: is_vmalloc_addr can be boolean
  mm/lru: is_file/active_lru can be boolean
  mm/mempolicy: vma_migratable can be boolean

 include/linux/hugetlb_inline.h |  6 +++---
 include/linux/memory_hotplug.h |  6 +++---
 include/linux/mempolicy.h      | 10 +++++-----
 include/linux/mm.h             |  4 ++--
 include/linux/mmzone.h         |  4 ++--
 mm/memory_hotplug.c            |  6 +++---
 6 files changed, 18 insertions(+), 18 deletions(-)

-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
