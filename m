Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3FE8C7618D
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:17:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9074E20644
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:17:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9074E20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED2CE6B0003; Mon, 15 Jul 2019 02:17:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5BAD6B0006; Mon, 15 Jul 2019 02:17:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFDE96B0007; Mon, 15 Jul 2019 02:17:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0836B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 02:17:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so12859647ede.23
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:17:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ykBrGAF9Osy4u6Kgs6RJe3emPurKJEmaSL5DLPZKttA=;
        b=gLyhRWLex+n6xZwxWjQQxsXqaLnV3ED1QTHa+z8DhLPzPh2g2a6VAgzxDKw+Mewy8u
         ZzTD6KIWql8IlAb2Jwi3MrKmZJXaEGD40HyUgeiFdMHQ2gjJCOPXFzjM2T+TKtCboIIR
         ATEtuxbLsE1UyInCYI2UMyHdpw9Lg9BsxrIMcUI9J3Tpj8b7zAzrJtwwjtqARi6tt153
         ripvDjQ68fakMMVakIbk20vw0TMQeC2K1dZAyWKQeJ+1cH4PMfsfTsVaBcQia0lFGsn6
         5G8OuA1H/Ekx7XLzEFeRJWAHN8gD7r0yRFgUmZCLZ8ygw9kghL7GdW/8uIFZ+9gTkN78
         Bwkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVAXr65oHSAmM//t9hxDy9DHBbBsJfpJPJNTlN7dh92xvN7MlQF
	1tNMtFs8Po5LYEONrkAMxwcXYFKceFPYMLBLbxOnZXgsAaAIXYFu/rGG3L0/KG9kBzWIe0BbEry
	+Knkpe9KXwbNXKGo47CVz9l9Lf83YgtIjYXiKcENCNX9y6EAMB84pG3QqCy98RHydmA==
X-Received: by 2002:a50:b3fb:: with SMTP id t56mr21295832edd.303.1563171447842;
        Sun, 14 Jul 2019 23:17:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzo8PSX6keWQu2nEtgoWciQMQRZg9CpXLfC+AJBwX8uhNOSNgBkxn5wRDO6XVJMVtuEUt95
X-Received: by 2002:a50:b3fb:: with SMTP id t56mr21295758edd.303.1563171446367;
        Sun, 14 Jul 2019 23:17:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563171446; cv=none;
        d=google.com; s=arc-20160816;
        b=yURuAFinUgmTFZYyRRjzu7yNM5qFdmF2CRtlTbRFp2Wcnhmu0WCURKyh4dlaHGXcNy
         h/KbZvXMJdPS+njVS0tv0+CWSc0sfDQB7cj8nVgDMyF2rz75AR3SN8iV/VA1Sgz7LiKO
         twpKxk9fVhQUR/A5MbvWLRprarrDiRF72vpY2rqCAmnAKL7eZ7G8tYOo0+ugoqpoY4ZN
         f3rvwHhON/DBI4QdbLoDyYhKDeDVWPRFj3Q67PI0/YpazGZCnfbzladQYUUPkvJFJGcJ
         DyRZAQl3+YKVU671mzkrIdTEvh0PRpjt5sGtJ2LO/Fwss1t+HtxaxwmkOymOVrcHr8XH
         pjZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ykBrGAF9Osy4u6Kgs6RJe3emPurKJEmaSL5DLPZKttA=;
        b=uQukdkUZF7PDRr/esAvQnJc79e1XInUcG/BKx1gdZm4EyDWrEQBYt3OuIFs2i6zlOq
         KpU6oBdknGnozw/IcVs1tOD7GOSyytbg83tT/sAEhd4oHKwcXnLv1l+RYS2fxpc/nc5u
         c4yi+05HZeVTTId3HsdnO0yobPwQW5zryWSrYIrEvqUmvjPeqbByLypXnxAXzDrHr/0T
         Tsgz9UOCeGh1PHNfozWm39SqFsneLYTnWvDdYBRfJUb2HOvTMe6vy+NoXlA+geCr/ZL8
         LhxSbQ6y2X34LeqU2lNiRhpdRUakHvbcYGyNj4SXKzKocmDZZ+eRdfACXp9vgZlHSMTD
         W5+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y12si9968420edd.87.2019.07.14.23.17.25
        for <linux-mm@kvack.org>;
        Sun, 14 Jul 2019 23:17:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4C993337;
	Sun, 14 Jul 2019 23:17:25 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.143])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 015AB3F71F;
	Sun, 14 Jul 2019 23:19:18 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will.deacon@arm.com
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	james.morse@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com,
	steve.capper@arm.com
Subject: [PATCH V6 RESEND 0/3] arm64/mm: Enable memory hot remove
Date: Mon, 15 Jul 2019 11:47:47 +0530
Message-Id: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series enables memory hot remove on arm64 after fixing a memblock
removal ordering problem in generic try_remove_memory() and a possible
arm64 platform specific kernel page table race condition. This series
is based on linux-next (next-20190712).

Concurrent vmalloc() and hot-remove conflict:

As pointed out earlier on the v5 thread [2] there can be potential conflict
between concurrent vmalloc() and memory hot-remove operation. This can be
solved or at least avoided with some possible methods. The problem here is
caused by inadequate locking in vmalloc() which protects installation of a
page table page but not the walk or the leaf entry modification.

Option 1: Making locking in vmalloc() adequate

Current locking scheme protects installation of page table pages but not the
page table walk or leaf entry creation which can conflict with hot-remove.
This scheme is sufficient for now as vmalloc() works on mutually exclusive
ranges which can proceed concurrently only if their shared page table pages
can be created while inside the lock. It achieves performance improvement
which will be compromised if entire vmalloc() operation (even if with some
optimization) has to be completed under a lock.

Option 2: Making sure hot-remove does not happen during vmalloc()

Take mem_hotplug_lock in read mode through [get|put]_online_mems() constructs
for the entire duration of vmalloc(). It protects from concurrent memory hot
remove operation and does not add any significant overhead to other concurrent
vmalloc() threads. It solves the problem in right way unless we do not want to
extend the usage of mem_hotplug_lock in generic MM.

Option 3: Memory hot-remove does not free (conflicting) page table pages

Don't not free page table pages (if any) for vmemmap mappings after unmapping
it's virtual range. The only downside here is that some page table pages might
remain empty and unused until next memory hot-add operation of the same memory
range.

Option 4: Dont let vmalloc and vmemmap share intermediate page table pages

The conflict does not arise if vmalloc and vmemap range do not share kernel
page table pages to start with. If such placement can be ensured in platform
kernel virtual address layout, this problem can be successfully avoided.

There are two generic solutions (Option 1 and 2) and two platform specific
solutions (Options 2 and 3). This series has decided to go with (Option 3)
which requires minimum changes while self-contained inside the functionality.

Testing:

Memory hot remove has been tested on arm64 for 4K, 16K, 64K page config
options with all possible CONFIG_ARM64_VA_BITS and CONFIG_PGTABLE_LEVELS
combinations. Its only build tested on non-arm64 platforms.

Changes in V6:

- Implemented most of the suggestions from Mark Rutland
- Added <linux/memory_hotplug.h> in ptdump
- remove_pagetable() now has two distinct passes over the kernel page table
- First pass unmap_hotplug_range() removes leaf level entries at all level
- Second pass free_empty_tables() removes empty page table pages
- Kernel page table lock has been dropped completely
- vmemmap_free() does not call freee_empty_tables() to avoid conflict with vmalloc()
- All address range scanning are converted to do {} while() loop
- Added 'unsigned long end' in __remove_pgd_mapping()
- Callers need not provide starting pointer argument to free_[pte|pmd|pud]_table() 
- Drop the starting pointer argument from free_[pte|pmd|pud]_table() functions
- Fetching pxxp[i] in free_[pte|pmd|pud]_table() is wrapped around in READ_ONCE()
- free_[pte|pmd|pud]_table() now computes starting pointer inside the function
- Fixed TLB handling while freeing huge page section mappings at PMD or PUD level
- Added WARN_ON(!page) in free_hotplug_page_range()
- Added WARN_ON(![pm|pud]_table(pud|pmd)) when there is no section mapping

- [PATCH 1/3] mm/hotplug: Reorder memblock_[free|remove]() calls in try_remove_memory()
- Request earlier for separate merger (https://patchwork.kernel.org/patch/10986599/)
- s/__remove_memory/try_remove_memory in the subject line
- s/arch_remove_memory/memblock_[free|remove] in the subject line
- A small change in the commit message as re-order happens now for memblock remove
  functions not for arch_remove_memory()

Changes in V5: (https://lkml.org/lkml/2019/5/29/218)

- Have some agreement [1] over using memory_hotplug_lock for arm64 ptdump
- Change 7ba36eccb3f8 ("arm64/mm: Inhibit huge-vmap with ptdump") already merged
- Dropped the above patch from this series
- Fixed indentation problem in arch_[add|remove]_memory() as per David
- Collected all new Acked-by tags
 
Changes in V4: (https://lkml.org/lkml/2019/5/20/19)

- Implemented most of the suggestions from Mark Rutland
- Interchanged patch [PATCH 2/4] <---> [PATCH 3/4] and updated commit message
- Moved CONFIG_PGTABLE_LEVELS inside free_[pud|pmd]_table()
- Used READ_ONCE() in missing instances while accessing page table entries
- s/p???_present()/p???_none() for checking valid kernel page table entries
- WARN_ON() when an entry is !p???_none() and !p???_present() at the same time
- Updated memory hot-remove commit message with additional details as suggested
- Rebased the series on 5.2-rc1 with hotplug changes from David and Michal Hocko
- Collected all new Acked-by tags

Changes in V3: (https://lkml.org/lkml/2019/5/14/197)
 
- Implemented most of the suggestions from Mark Rutland for remove_pagetable()
- Fixed applicable PGTABLE_LEVEL wrappers around pgtable page freeing functions
- Replaced 'direct' with 'sparse_vmap' in remove_pagetable() with inverted polarity
- Changed pointer names ('p' at end) and removed tmp from iterations
- Perform intermediate TLB invalidation while clearing pgtable entries
- Dropped flush_tlb_kernel_range() in remove_pagetable()
- Added flush_tlb_kernel_range() in remove_pte_table() instead
- Renamed page freeing functions for pgtable page and mapped pages
- Used page range size instead of order while freeing mapped or pgtable pages
- Removed all PageReserved() handling while freeing mapped or pgtable pages
- Replaced XXX_index() with XXX_offset() while walking the kernel page table
- Used READ_ONCE() while fetching individual pgtable entries
- Taken overall init_mm.page_table_lock instead of just while changing an entry
- Dropped previously added [pmd|pud]_index() which are not required anymore
- Added a new patch to protect kernel page table race condition for ptdump
- Added a new patch from Mark Rutland to prevent huge-vmap with ptdump

Changes in V2: (https://lkml.org/lkml/2019/4/14/5)

- Added all received review and ack tags
- Split the series from ZONE_DEVICE enablement for better review
- Moved memblock re-order patch to the front as per Robin Murphy
- Updated commit message on memblock re-order patch per Michal Hocko
- Dropped [pmd|pud]_large() definitions
- Used existing [pmd|pud]_sect() instead of earlier [pmd|pud]_large()
- Removed __meminit and __ref tags as per Oscar Salvador
- Dropped unnecessary 'ret' init in arch_add_memory() per Robin Murphy
- Skipped calling into pgtable_page_dtor() for linear mapping page table
  pages and updated all relevant functions

Changes in V1: (https://lkml.org/lkml/2019/4/3/28)

References:

[1] https://lkml.org/lkml/2019/5/28/584
[2] https://lkml.org/lkml/2019/6/11/709

Anshuman Khandual (3):
  mm/hotplug: Reorder memblock_[free|remove]() calls in try_remove_memory()
  arm64/mm: Hold memory hotplug lock while walking for kernel page table dump
  arm64/mm: Enable memory hot remove

 arch/arm64/Kconfig             |   3 +
 arch/arm64/mm/mmu.c            | 290 +++++++++++++++++++++++++++++++++++++++--
 arch/arm64/mm/ptdump_debugfs.c |   4 +
 mm/memory_hotplug.c            |   4 +-
 4 files changed, 290 insertions(+), 11 deletions(-)

-- 
2.7.4

