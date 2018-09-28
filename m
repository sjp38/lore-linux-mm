Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE7708E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:37:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a18-v6so5643653pgn.10
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 22:37:41 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id i21-v6si3951333pfo.333.2018.09.27.22.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 22:37:40 -0700 (PDT)
Date: Fri, 28 Sep 2018 13:34:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] mm: fix __get_user_pages_fast() comment
Message-ID: <20180928053441.rpzwafzlsnp74mkl@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

mmu_gather_tlb no longer exist. Replace with mmu_table_batch.

CC: trivial@kernel.org
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/gup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index fc5f98069f4e..69194043ddd4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1798,8 +1798,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * interrupts disabled by get_futex_key.
 	 *
 	 * With interrupts disabled, we block page table pages from being
-	 * freed from under us. See mmu_gather_tlb in asm-generic/tlb.h
-	 * for more details.
+	 * freed from under us. See struct mmu_table_batch comments in
+	 * include/asm-generic/tlb.h for more details.
 	 *
 	 * We do not adopt an rcu_read_lock(.) here as we also want to
 	 * block IPIs that come from THPs splitting.
-- 
2.15.0
