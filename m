Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0ABE6B42CC
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:07:33 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id e10so8790588oth.21
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:07:33 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b3si375578oib.69.2018.11.26.09.07.31
        for <linux-mm@kvack.org>;
        Mon, 26 Nov 2018 09:07:31 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v4 0/5] Clean up huge vmap and ioremap code
Date: Mon, 26 Nov 2018 17:07:42 +0000
Message-Id: <1543252067-30831-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

Hi all,

This is version four of the patches I previously posted here:

  v1: http://lkml.kernel.org/r/1536747974-25875-1-git-send-email-will.deacon@arm.com
  v2: http://lkml.kernel.org/r/1538478363-16255-1-git-send-email-will.deacon@arm.com
  v3: http://lkml.kernel.org/r/1539188584-15819-1-git-send-email-will.deacon@arm.com

The only change since v3 is a rebase onto v4.20-rc3, which was automatic.

I would appreciate a review of patch 4. Sean, please could you take a
quick look?

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
