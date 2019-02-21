Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF004C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:50:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77D4C2086A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:50:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77D4C2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25A7B8E00C4; Thu, 21 Feb 2019 18:50:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 208B48E00B5; Thu, 21 Feb 2019 18:50:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 120988E00C4; Thu, 21 Feb 2019 18:50:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE6458E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:50:55 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o67so313528pfa.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:50:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Z9tJaKnZS65C6V1H5KRVaqtPscrudYVfSyy/ThWNAz8=;
        b=mxrkypXTmNSB8Ksrb2laMXACf0/lNWgkGD/j5FysiCEqw0bZO5VY7mgdadxCsdght4
         JHr/bRjlGEom/Arfcel/0plQia+2vOLqcr4ITQHGP8vruqwbdRFAe8Vzw+DGBS/eCLa1
         dyErMFb9zM7UA6gtvGEIx8JI9+KfMAYs3sA6cMdPR8lvXhHCvgFdIbFbv9qtVks6yXr7
         Bag68tfF6Wo0vLO43ztbhpBQShysXKJelUByevfz69bemYW6gn6A8b6Jkzx8dqUTg26+
         JJGHU8OF64LsmunCPVOZ5kwJgfvCCj8KdqLQDIEnoT0hJ3mjhEAj2lbpzaXMWvX5vkIx
         aRGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYZS5XFRVOdND6mptFJ9wWeBjsM/LGBpf84Dk6KaunRY2rQzcrl
	SmZbg2FVY0gTq540A7qV3pSo0bD25zceabJsD7xQa8A7GCIpv7qpexyZx4uKMMzwVCBKzyeGyd2
	+MpxKqvmN4pegMTXe1mXQltxsvrjWxjgkXqCeJ0+dg734ys+sb090MHmwLAbtf9khRg==
X-Received: by 2002:a62:be0b:: with SMTP id l11mr1200832pff.52.1550793055407;
        Thu, 21 Feb 2019 15:50:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZavUH2SVyz6Ge/mwhTgXQiGPDNPEguZjsKLmPs7rPI35EkTYPrSD/Io80kzzckX8D5OYf+
X-Received: by 2002:a62:be0b:: with SMTP id l11mr1200759pff.52.1550793054128;
        Thu, 21 Feb 2019 15:50:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793054; cv=none;
        d=google.com; s=arc-20160816;
        b=DtCXCvX07SrQd7q3cJzcDcwz7Ye0PZaQqTj0enpqz2aFs3TM81EdCqQNGhYycsJRO4
         WoYR5PigFoA7NTBH5BXHIKrsEHJeaOL0izp4+DmTcTXA0WxFzyuaqdpFwxtDjq6/8+UW
         C1ztH6twz6AF4ev0Xqf3cxDuVNni9yeFMS9vyVjox41SHVF/0hoTiBeoVp70z1WPzFA4
         SNX0GkkVBc2slcI71kZouZ6MgZ2f3/JigohkiNnVrXYE+rtYG9pKw4YMUgz4bwO05HEy
         F6CUfaheWUzcadOJxnMegdtTPvNHbnXGK+ycB/8Jr2nj4XPajWNx44XMboWqUPmD7pWD
         RZyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Z9tJaKnZS65C6V1H5KRVaqtPscrudYVfSyy/ThWNAz8=;
        b=KCT174T3FizdO0FGdMwPhUQsBrDQMQSTYkEv849dkF1up5t9VMl8dzVRpHS/dAS/3T
         gU/xo/yn6/9/VIDRLYMlyX4s4hJHqY0Lv/6Pnp5jleA7LqVVvXIpMsMzOKtHY86M36Xb
         6W45Ie55aNQthkSAEEzdG2hhKNAWMn99GsCQsx/qmIuA/kJ7PVZdkrImrGc9aQFo5Tkg
         kc/flm60Nhu1UYiofzfuf1+CdkHPg35BtJeRrBWoxfdKmEF4CcurPuuD9yZRtRplxg06
         A1ndKaLYc8AQdCYVm4b8TwHrYUDQ9Eau3pNsOZueeQm+jfq0l29CchhR9ghosYzWjEfm
         Y6FA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:50:54 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:53 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394796"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:51 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 00/20] Merge text_poke fixes and executable lockdowns
Date: Thu, 21 Feb 2019 15:44:31 -0800
Message-Id: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset improves several overlapping issues around stale TLB entries and
W^X violations. It is combined from "x86/alternative: text_poke() enhancements
v7" [1] and "Don’t leave executable TLB entries to freed pages v2" [2] patchsets
that were conflicting.

The related issues that this fixes:
1. Fixmap PTEs that are used for patching are available for access from
   other cores and might be exploited. They are not even flushed from
   the TLB in remote cores, so the risk is even higher. Address this
   issue by introducing a temporary mm that is only used during
   patching. Unfortunately, due to init ordering, fixmap is still used
   during boot-time patching. Future patches can eliminate the need for
   it.
2. Missing lockdep assertion to ensure text_mutex is taken. It is
   actually not always taken, so fix the instances that were found not
   to take the lock (although they should be safe even without taking
   the lock).
3. Module_alloc returning memory that is RWX until a module is finished
   loading.
4. Sometimes when memory is freed via the module subsystem, an
   executable permissioned TLB entry can remain to a freed page. If the
   page is re-used to back an address that will receive data from
   userspace, it can result in user data being mapped as executable in
   the kernel. The root of this behavior is vfree lazily flushing the
   TLB, but not lazily freeing the underlying pages.


Changes v2 to v3:
 - Fix commit messages and comments [Boris]
 - Rename VM_HAS_SPECIAL_PERMS [Boris]
 - Remove unnecessary local variables [Boris]
 - Rename set_alias_*() functions [Boris, Andy]
 - Save/restore DR registers when using temporary mm
 - Move line deletion from patch 10 to patch 17

Changes v1 to v2:
 - Adding “Reviewed-by tag” [Masami]
 - Comment instead of code to warn against module removal while
   patching [Masami]
 - Avoiding open-coded TLB flush [Andy]
 - Remove "This patch" [Borislav Petkov]
 - Not set global bit during text poking [Andy, hpa]
 - Add Ack from [Pavel Machek]
 - Split patch 16 "Plug in new special vfree flag" into 4 patches (16-19)
   to make it easier to review. There were no code changes.

The changes from "Don’t leave executable TLB entries to freed pages
v2" to v1:
 - Add support for case of hibernate trying to save an unmapped page
   on the directmap. (Ard Biesheuvel)
 - No week arch breakout for vfree-ing special memory (Andy Lutomirski)
 - Avoid changing deferred free code by moving modules init free to work
   queue (Andy Lutomirski)
 - Plug in new flag for kprobes and ftrace
 - More arch generic names for set_pages functions (Ard Biesheuvel)
 - Fix for TLB not always flushing the directmap (Nadav Amit)
 
Changes from "x86/alternative: text_poke() enhancements v7" to v1
 - Fix build failure on CONFIG_RANDOMIZE_BASE=n (Rick)
 - Remove text_poke usage from ftrace (Nadav)
 
[1] https://lkml.org/lkml/2018/12/5/200
[2] https://lkml.org/lkml/2018/12/11/1571

Andy Lutomirski (1):
  x86/mm: Introduce temporary mm structs

Nadav Amit (12):
  x86/jump_label: Use text_poke_early() during early init
  x86/mm: Save DRs when loading a temporary mm
  fork: Provide a function for copying init_mm
  x86/alternative: Initialize temporary mm for patching
  x86/alternative: Use temporary mm for text poking
  x86/kgdb: Avoid redundant comparison of patched code
  x86/ftrace: Set trampoline pages as executable
  x86/kprobes: Set instruction page as executable
  x86/module: Avoid breaking W^X while loading modules
  x86/jump-label: Remove support for custom poker
  x86/alternative: Remove the return value of text_poke_*()
  x86/alternative: Comment about module removal races

Rick Edgecombe (7):
  x86/mm/cpa: Add set_direct_map_ functions
  mm: Make hibernate handle unmapped pages
  vmalloc: Add flag for free of special permsissions
  modules: Use vmalloc special flag
  bpf: Use vmalloc special flag
  x86/ftrace: Use vmalloc special flag
  x86/kprobes: Use vmalloc special flag

 arch/Kconfig                         |   4 +
 arch/x86/Kconfig                     |   1 +
 arch/x86/include/asm/fixmap.h        |   2 -
 arch/x86/include/asm/mmu_context.h   |  58 ++++++++++
 arch/x86/include/asm/pgtable.h       |   3 +
 arch/x86/include/asm/set_memory.h    |   3 +
 arch/x86/include/asm/text-patching.h |   6 +-
 arch/x86/kernel/alternative.c        | 153 +++++++++++++++++++++------
 arch/x86/kernel/ftrace.c             |  14 ++-
 arch/x86/kernel/jump_label.c         |  21 ++--
 arch/x86/kernel/kgdb.c               |  14 +--
 arch/x86/kernel/kprobes/core.c       |  19 +++-
 arch/x86/kernel/module.c             |   2 +-
 arch/x86/mm/init_64.c                |  36 +++++++
 arch/x86/mm/pageattr.c               |  16 +--
 arch/x86/xen/mmu_pv.c                |   2 -
 include/linux/filter.h               |  18 +---
 include/linux/mm.h                   |  18 ++--
 include/linux/sched/task.h           |   1 +
 include/linux/set_memory.h           |  10 ++
 include/linux/vmalloc.h              |  13 +++
 init/main.c                          |   3 +
 kernel/bpf/core.c                    |   1 -
 kernel/fork.c                        |  24 +++--
 kernel/module.c                      |  82 +++++++-------
 kernel/power/snapshot.c              |   5 +-
 mm/page_alloc.c                      |   7 +-
 mm/vmalloc.c                         | 113 ++++++++++++++++----
 28 files changed, 475 insertions(+), 174 deletions(-)

-- 
2.17.1

