Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81D59C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5457B20665
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5457B20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3B5F6B0005; Wed, 29 May 2019 05:16:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEBB66B000C; Wed, 29 May 2019 05:16:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB4AF6B0010; Wed, 29 May 2019 05:16:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5726B0005
	for <linux-mm@kvack.org>; Wed, 29 May 2019 05:16:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r5so2415575edd.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 02:16:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=0HBTjfcsqLCMcaqYk1MIdOQjklPHBodMLoi7QZIn4rg=;
        b=ni+ozEv2qPV67QM2Rw2gD6kWOXN+cZh2OtVi83UstD8tGS1vdUiTWhgTMpL2zvE8ra
         q8STHdjoXICUvNCAwtP3BYQt6ndDDjVugm+1gMccP4OVkWB8F2aq9Tqg3rA11vEGC2gh
         e2QrPCe37JoiXVRBwV9wQ37hnLwwC93T60e0YWaWxVeFSVW7cTBnSkVF++Leu6N9aQch
         sK5CxgmX0OhqIaXjznKIGPTCLd/S8pVmQHqhdx9Cf2WyAg6taLy/6EKp6T0ytDUcE1wv
         335OxPOZIbM7y7NVu66dQCaDM6eM+iD/Az4iDeu5Tl8+5/ix4TRo07PxbAr7EHK9TyTA
         xpIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUrgtC7XiE3b9eNww8VHnG+l96UBio6K9Fwy/ZX/ftm5tQvoaN0
	WAbr2Ri0HPxRO4Tmqt/i6M7YFMx3sn8AVORnIj5kSjIyopCILdisIjIMKetn3CIN81OErMJVbZM
	VMLHr6NLpoMhA+mgwDm28sel9l3sPnBCYgm3wmdnxIekl2K8bvZn6WEcjSNtFHVfEGA==
X-Received: by 2002:a17:906:63c1:: with SMTP id u1mr44966284ejk.173.1559121385646;
        Wed, 29 May 2019 02:16:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPiZzBY59WYgawB2dW7Z0uWKVZlhXbMdKagWEkJQNzNHksqiNohD9nomznrSEfCMb89Afi
X-Received: by 2002:a17:906:63c1:: with SMTP id u1mr44966226ejk.173.1559121384627;
        Wed, 29 May 2019 02:16:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559121384; cv=none;
        d=google.com; s=arc-20160816;
        b=JyYECpdbEI0uKtfcTbA+7F0CKy9lgOJ/K/xHZpR49Kh9fwBM0mtiyep5YN9T7J4amx
         eHXT6SGCTvsA9/6xuXLn07Nhbux1EIqzRPNm2IcKvXioU7e35mLUeNZ3X7quIfYrW+iY
         qq/eqjfPWw6mXbtSHAfOYVEkKkzeuJCcdZyQlaIZ8dmObHduk1mkPfm2eAGaEuDoJy4P
         cAOXBZ7BtLv3Lgabtx4kZx/IaEONU3VqkcVVvafhGGILovbEx5kU7Thdd+2ZvCn5lOVM
         F7VE+cOKJ0vTa/WpyBlyKteDnf2AMmtnNKkzsJ8PJ66EG8NwubfF0w8msHEHdyP99B1Y
         7yXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=0HBTjfcsqLCMcaqYk1MIdOQjklPHBodMLoi7QZIn4rg=;
        b=K78kywhyMUjnC9FoNP3+mI7VYadrMGdclJSIQxrqIP6hFndOhZdQ+xftgNFV12QsTY
         P7S3K7LFJh0gQ/UNcUBiCD4f5IbqHoeZzqzPF3tmw7Uq1LWU8tR+I4B+kdNBw5wEDG1Y
         cuDnZ5AoZyDYG/mM1CDJkuyXsP7N46QWpUdpuAJNemrvR/0JSPVF/qj5S0VrCS2uHBbp
         HHXxnPN055jp6c+qlbE3t+eupa0eW4BQdCNhNjTQ0HH8NiR06VNxG2uc2Uf8xTI/mqNL
         qwhOIs8KAlWvUg0RbNXHWFMe1NgqLvROL5pRp2CO45tpLlNwQc9DiTnpjp46Q2tmH31R
         P8/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d8si11630808ejm.200.2019.05.29.02.16.23
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 02:16:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F2311341;
	Wed, 29 May 2019 02:16:22 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.181])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id B1B0E3F5AF;
	Wed, 29 May 2019 02:16:17 -0700 (PDT)
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
	ard.biesheuvel@arm.com
Subject: [PATCH V5 0/3] arm64/mm: Enable memory hot remove
Date: Wed, 29 May 2019 14:46:24 +0530
Message-Id: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series enables memory hot remove on arm64 after fixing a memblock
removal ordering problem in generic __remove_memory() and one possible
arm64 platform specific kernel page table race condition. This series
is based on latest v5.2-rc2 tag.

Testing:

Memory hot remove has been tested on arm64 for 4K, 16K, 64K page config
options with all possible CONFIG_ARM64_VA_BITS and CONFIG_PGTABLE_LEVELS
combinations. Its only build tested on non-arm64 platforms.

Changes in V5:

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

[1] https://lkml.org/lkml/2019/5/28/584

Anshuman Khandual (3):
  mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
  arm64/mm: Hold memory hotplug lock while walking for kernel page table dump
  arm64/mm: Enable memory hot remove

 arch/arm64/Kconfig             |   3 +
 arch/arm64/mm/mmu.c            | 211 ++++++++++++++++++++++++++++++++++++++++-
 arch/arm64/mm/ptdump_debugfs.c |   3 +
 mm/memory_hotplug.c            |   2 +-
 4 files changed, 216 insertions(+), 3 deletions(-)

-- 
2.7.4

