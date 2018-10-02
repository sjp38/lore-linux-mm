Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 432506B026A
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 07:05:42 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id e15-v6so989821oie.16
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 04:05:42 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s7-v6si7901319ota.201.2018.10.02.04.05.40
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 04:05:40 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 0/5] Clean up huge vmap and ioremap code
Date: Tue,  2 Oct 2018 12:05:58 +0100
Message-Id: <1538478363-16255-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

Hi all,

This is version two of the patches I previously posted here:

  http://lkml.kernel.org/r/1536747974-25875-1-git-send-email-will.deacon@arm.com

Changes since v1 include:

  * Fixed increment of the physical address around the mapping loops
  * Added Reviewed-by tags from Toshi

All feedback welcome,

Will

--->8

Will Deacon (5):
  ioremap: Rework pXd_free_pYd_page() API
  arm64: mmu: Drop pXd_present() checks from pXd_free_pYd_table()
  x86: pgtable: Drop pXd_none() checks from pXd_free_pYd_table()
  lib/ioremap: Ensure phys_addr actually corresponds to a physical
    address
  lib/ioremap: Ensure break-before-make is used for huge p4d mappings

 arch/arm64/mm/mmu.c           |  13 +++---
 arch/x86/mm/pgtable.c         |  14 +++---
 include/asm-generic/pgtable.h |   5 ++
 lib/ioremap.c                 | 103 +++++++++++++++++++++++++++++-------------
 4 files changed, 91 insertions(+), 44 deletions(-)

-- 
2.1.4
