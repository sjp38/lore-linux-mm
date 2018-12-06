Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45BBB6B7B4F
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 13:21:17 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id b18so612393oii.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 10:21:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w5si392143otj.24.2018.12.06.10.21.15
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 10:21:16 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [RESEND PATCH v4 0/5] Clean up huge vmap and ioremap code
Date: Thu,  6 Dec 2018 18:21:30 +0000
Message-Id: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

Hi all,

This is a resend of version four of the patches I previously posted here:

  v1: http://lkml.kernel.org/r/1536747974-25875-1-git-send-email-will.deacon@arm.com
  v2: http://lkml.kernel.org/r/1538478363-16255-1-git-send-email-will.deacon@arm.com
  v3: http://lkml.kernel.org/r/1539188584-15819-1-git-send-email-will.deacon@arm.com
  v4: http://lkml.kernel.org/r/1543252067-30831-1-git-send-email-will.deacon@arm.com

The only difference from v4 is that I have added Sean's Reviewed-by to the
core change.

Andrew, please can you take this via your tree for 4.21?

Thanks,

Will

--->8

Will Deacon (5):
  ioremap: Rework pXd_free_pYd_page() API
  arm64: mmu: Drop pXd_present() checks from pXd_free_pYd_table()
  x86/pgtable: Drop pXd_none() checks from pXd_free_pYd_table()
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
