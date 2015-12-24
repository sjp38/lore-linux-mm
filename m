Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id D09D282F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 06:52:01 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id q3so127329078pav.3
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 03:52:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 12si5455172pfm.98.2015.12.24.03.51.58
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 03:51:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] THP updates
Date: Thu, 24 Dec 2015 14:51:19 +0300
Message-Id: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrew,

Patches below fixes two mlock-related bugs and increase rate of success
for split_huge_page().

I also implemented debugfs handle to split all huge pages in the system.
It's useful for debugging.

Kirill A. Shutemov (4):
  thp: add debugfs handle to split all huge pages
  thp: fix regression in handling mlocked pages in __split_huge_pmd()
  mm: stop __munlock_pagevec_fill() if THP enounted
  thp: increase split_huge_page() success rate

 mm/huge_memory.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 mm/mlock.c       |  7 ++++++
 2 files changed, 72 insertions(+), 5 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
