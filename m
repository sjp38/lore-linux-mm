Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41C6B6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 12:23:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 36so3961527ott.22
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 09:23:15 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 79-v6si11620637oib.54.2018.10.10.09.23.13
        for <linux-mm@kvack.org>;
        Wed, 10 Oct 2018 09:23:14 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v3 0/5] Clean up huge vmap and ioremap code
Date: Wed, 10 Oct 2018 17:22:59 +0100
Message-Id: <1539188584-15819-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

Hi all,

This is version three of the patches I previously posted here:

  v1: http://lkml.kernel.org/r/1536747974-25875-1-git-send-email-will.deacon@arm.com
  v2: http://lkml.kernel.org/r/1538478363-16255-1-git-send-email-will.deacon@arm.com

The only changes since v2 are to the commit messages.

All feedback welcome,

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
