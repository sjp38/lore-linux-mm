Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 58FD06B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 13:04:52 -0400 (EDT)
Received: by ykeo3 with SMTP id o3so121036643yke.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 10:04:52 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id y184si3883262yky.22.2015.07.09.10.04.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 10:04:50 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 0/2] x86, mm: Fix PAT bit handling of large pages 
Date: Thu,  9 Jul 2015 11:03:49 -0600
Message-Id: <1436461431-27305-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
is corrently used for masking the flag bits for all cases. 

Patch 1/2 fixes pud_flags() and pmd_flags() to handle the PAT bit
when PUD and PMD mappings are used.

Patch 2/2 fixes /sys/kernel/debug/kernel_page_tables to show the
PAT bit properly.

Note, the PAT bit is first enabled in 4.2-rc1 with WT mappings.

---
Toshi Kani (2):
  1/2 x86: Fix pXd_flags() to handle _PAGE_PAT_LARGE
  2/2 x86, mm: Fix page table dump to show PAT bit

---
 arch/x86/include/asm/pgtable_types.h | 16 ++++++++++++---
 arch/x86/mm/dump_pagetables.c        | 39 +++++++++++++++++++-----------------
 2 files changed, 34 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
