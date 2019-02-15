Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AA2DC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5317821924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5317821924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C87228E0003; Fri, 15 Feb 2019 12:03:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C388E8E0001; Fri, 15 Feb 2019 12:03:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C508E0003; Fri, 15 Feb 2019 12:03:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8338E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:06 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o14so2230400edr.15
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=OLdK6qnJVeZJFxiIfOrWpKFHM3h9lXf0pOIxynRsQ60=;
        b=hU/c45ifDPfWNbmzWGolokBYNUhct/r/aeAZQXy3O99EInshLs7CQCe6cgvO+wZTZG
         ye8m7npouWZJlTTqFZUI/iqeVBFkNgazNRuLRHsY5A4dR6cPs1QGdiYRrk6DubOlc1NQ
         uwMgiXGSqUP3/xB22QC/jpvUS5zQwq9TccOJJNDiGVozDf8vnGSYuZF2fA2jAudV9f/G
         d3tPSvDeonVYCH2bZAROs87BoFKDVjiseOr3SyfEVYFT7PX8Rk9xeG7oi0Kwagk6Woe7
         R9s+cEm7twhH6h4k5tGdIXjTaPK1IDdiOaV5pA9x9BRld07Ck5qJtRmBC6p+nS/xFovV
         swsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAub3S5SHMtNovkj4UxXDBkUU43ibSlYEsU7EW+JewSumwOK8gGUp
	PtF8PKO3ZexYii+4Wne4qV2xI8nN45Ln93REhZ4Bez8EDF3H5Tyc1l+WtekeAjf0QjGqy9BOqIX
	SMYbIFF7TkErL9fc+mUa1uA+SVKtUxa0pqXE8oQ9lUb9e9OqeQi+U88fAFGPIuykVDA==
X-Received: by 2002:a17:906:7c49:: with SMTP id g9mr255911ejp.31.1550250185848;
        Fri, 15 Feb 2019 09:03:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZvwqBc97VVuvgnXQhi3v9Wu8olHHty27Ais4FcLUlNqq3QL/hegMv13a+Rk5DPsE0yzAR0
X-Received: by 2002:a17:906:7c49:: with SMTP id g9mr255838ejp.31.1550250184682;
        Fri, 15 Feb 2019 09:03:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250184; cv=none;
        d=google.com; s=arc-20160816;
        b=McbJyKMXtJV7AIpdms/xssM+4oRTRFm3/Af/r27+KlMIPj5tpuz46GW6WGL9YvKLBV
         X32VDg575QmN3TGKMEokKB7gqjwq0stqMJySFNsM5HwAAboPnBqupMgde2A+6N9eo58q
         7k8ZYxWSEp5bxsIj9zN/IRyH0MWR0J/90UgeToYbgBQb3K7eHMfwFT/5vRrbuM6v7gbu
         Bo5C9qgPZSDgUKcmX1dIitTcQl7O2M2suWgAIzv9zYcO8iI6/UlQDCiVi7+LA2U0JeRR
         FNu49orzmQwb8h/rBunDULOOae3SGDgEJnR745CyRASyM1turVKLznOMCgtl/VbntviG
         5a9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=OLdK6qnJVeZJFxiIfOrWpKFHM3h9lXf0pOIxynRsQ60=;
        b=IPtAXeStNSHAUeyT9FpAzPlBWB8a1L6mBlI8iqVbL1QQ1+SMAewb0qJrsUt9sf8PSF
         wt+TkkLKIMqvzQoE5xmFoNqgVTuYlAlJk8b9EyzQqesqoP5M7t1iW/hsWvi1bfVn8Aui
         4CCZHx4iSpfRrSeMxq7vR2o3u9gbc+c6ITDi+5qqXi3Mq0cB4NWACxUqnV7d9Z0SLLON
         bfkGPHZfFvJLLTLQJoy/CjLwcW0Pzcb4C/BogRbb3Tb8WFbaGIS4laOBzb36sp9catBW
         litSvmIw4Oxsdp+jusB6dVkyfsB9ELe35XKoh5scihuTueA0X1WokuHBhbu7Upqdj/FI
         dWrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p7si2414492ejj.19.2019.02.15.09.03.04
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:04 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9A0F8EBD;
	Fri, 15 Feb 2019 09:03:03 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A5A373F557;
	Fri, 15 Feb 2019 09:03:00 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 00/13] Convert x86 & arm64 to use generic page walk
Date: Fri, 15 Feb 2019 17:02:21 +0000
Message-Id: <20190215170235.23360-1-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Most architectures current have a debugfs file for dumping the kernel
page tables. Currently each architecture has to implement custom
functions for walking the page tables because the generic
walk_page_range() function is unable to walk the page tables used by the
kernel.

This series extends the capabilities of walk_page_range() so that it can
deal with the page tables of the kernel (which have no VMAs and can
contain larger huge pages than exist for user space). x86 and arm64 are
then converted to make use of walk_page_range() removing the custom page
table walkers.

Potentially future changes could unify the implementations of the
debugfs walkers further, moving the common functionality into common
code. This would require a common way of handling the effective
permissions (currently implemented only for x86) along with a per-arch
way of formatting the page table information for debugfs. One
immediate benefit would be getting the KASAN speed up optimisation in
arm64 (and other arches) which is currently only implemented for x86.

James Morse (2):
  arm64: mm: Add p?d_large() definitions
  mm: Add generic p?d_large() macros

Steven Price (11):
  x86/mm: Add p?d_large() definitions
  mm: pagewalk: Add p4d_entry() and pgd_entry()
  mm: pagewalk: Allow walking without vma
  mm: pagewalk: Add 'depth' parameter to pte_hole
  mm: pagewalk: Add test_p?d callbacks
  arm64: mm: Convert mm/dump.c to use walk_page_range()
  x86/mm: Point to struct seq_file from struct pg_state
  x86/mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
  x86/mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
  x86/mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
  x86: mm: Convert dump_pagetables to use walk_page_range

 arch/arm64/include/asm/pgtable.h |   2 +
 arch/arm64/mm/dump.c             | 108 +++++-----
 arch/x86/include/asm/pgtable.h   |   8 +-
 arch/x86/mm/debug_pagetables.c   |   8 +-
 arch/x86/mm/dump_pagetables.c    | 342 ++++++++++++++++---------------
 arch/x86/platform/efi/efi_32.c   |   2 +-
 arch/x86/platform/efi/efi_64.c   |   4 +-
 fs/proc/task_mmu.c               |   4 +-
 include/asm-generic/pgtable.h    |  10 +
 include/linux/mm.h               |  25 ++-
 mm/hmm.c                         |   2 +-
 mm/migrate.c                     |   1 +
 mm/mincore.c                     |   1 +
 mm/pagewalk.c                    |  92 ++++++---
 14 files changed, 350 insertions(+), 259 deletions(-)

-- 
2.20.1

