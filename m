Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21DCBC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D082721738
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D082721738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8159C6B000A; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C7796B0010; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6671A6B000D; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9166B0008
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h14so8432326pgn.23
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=7B+CL5Sto9KU/VBigp9SJGxY8kRqK761XCrRvI17bdQ=;
        b=iifLdm4ui5wzKQ8XUmzNARk7CcXeENwnDTOZqMcCPy8DOA6mIYrcIFZsDNZumm2NX/
         xfG+nA5nIOc0qswxRc04xIQMI3pZ+6jEQqsEf6e0Odv3JQDQs2Yre/nLLFlXqkcLxVUl
         zyC8P5gIaQ2pFXQzzVqu6QOmL4xpyNWXlztzCmzZohv8yB4Hm7s34iUyER4VrN87WYjc
         8t3T0mDWvilu0qV5PDJN3gY3NN9QQLCSCyKDc1Qz2RLVi/X4mrYXNbJlAmqXFx3y/QhA
         ULaMerANofEOdXpcdOhc1DklwZ12hJyE0HZSoKUfKNLW2CkJ9imtSLqq0McMjksJ2OV/
         pE2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWlDiBqLgCR6X9A2i9rhQ/Pijg68WZMKOlwgeudNVUSfECyJTCG
	y4ZR2ke/ObyC3faJ+g4OPSIHh7qXHJ+maaQLh3TbmWu1EDpSsElCOIzh9yqxk6ZAmFv8I/CpK0j
	StQ+eX9vI8g4FWnz1QHkcq1NN1SLRHULX4EkFzegu9mKO4q96HX3akL/Do6RY7MEBqA==
X-Received: by 2002:a63:d04b:: with SMTP id s11mr534989pgi.137.1555959523609;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGr0zxhULJJ2/q/B5HLYtAIL1D4lMZscKs1D384W1xqIsf+Ut+CGz0G0rCRYZoyiDxg9ep
X-Received: by 2002:a63:d04b:: with SMTP id s11mr534933pgi.137.1555959522582;
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959522; cv=none;
        d=google.com; s=arc-20160816;
        b=uZpiB4XSFsorbZbYYAIZxGLQntaHdLznp3a1FqTW2JDs9LlGyUfjqyZedW68zk/7CA
         xqKLylU6LamJ7dTTh5yqHxCaVpWZX7kHvW2PCciLySqQdfIS1fz5M6XTGSGXIXVWisKp
         Qm4XA8lxJHnB4Ipv/RhgY7hhDHRdvA12JD0fNh6K7RqzZnry1u36VBCzbGU/gsEzTw6l
         jwm6ShAVoILAu/weeJaHh2wBzFZUqCgQJAdkH4UpGyEbVZkNz7u3bVqBBrqTZiz1UJbx
         RtFBDDlf+S7pQQ9vqCuxmX31tA6SbDSQQqlFEdyfywSCA6PraR+UXwpvM2hG24wfkQE0
         Nipw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=7B+CL5Sto9KU/VBigp9SJGxY8kRqK761XCrRvI17bdQ=;
        b=loTd6n0fyxlfUuFGwMseD69uq4X4e5fmdVCgGmAQtb1j5ExSa+H93+gSnOuvhFrXTR
         wxsjDPyF4TTvZwdguq2f570qSOxZg5kDXp1x8lpJpYei8n6p6U9pGOUnaNZiHKk0XV/X
         fkXDUQDKc6ntPWiuYmDLBlie3GKDtiqSWi2QeyVt7WgG5YqPYEjkAonY420FRYWeBHD1
         zORhKhTf77nMnbTAOzBi/9xQyjbEVoc3b1KWoFQZLFm66cT8zhFgoBUj9klvTmsYUxXL
         YEqA+DVkhavJkGIV+pHP78dsOTfnszGjBs8XdD/Rv+zH6W28tX5qG0QaxFe2dSRivETz
         Vxgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417117"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:40 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
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
Subject: [PATCH v4 00/23] Merge text_poke fixes and executable lockdowns
Date: Mon, 22 Apr 2019 11:57:42 -0700
Message-Id: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Picking this up again after seeing how things shook out around the issue
raised here: https://lkml.org/lkml/2019/2/22/702

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

Changes v3 to v4:
 - Remove the size parameter from tramp_free() [Steven]
 - Remove caching of hw_breakpoint_active() [Sean]
 - Prevent the use of bpf_probe_write_user() while using temporary mm [Jann]
 - Fix build issues on other archs

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

Nadav Amit (15):
  Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
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
  tlb: provide default nmi_uaccess_okay()
  bpf: Fail bpf_probe_write_user() while mm is switched

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
 arch/x86/include/asm/mmu_context.h   |  56 ++++++++
 arch/x86/include/asm/pgtable.h       |   3 +
 arch/x86/include/asm/set_memory.h    |   3 +
 arch/x86/include/asm/text-patching.h |   7 +-
 arch/x86/include/asm/tlbflush.h      |   2 +
 arch/x86/kernel/alternative.c        | 201 ++++++++++++++++++++-------
 arch/x86/kernel/ftrace.c             |  22 +--
 arch/x86/kernel/jump_label.c         |  21 ++-
 arch/x86/kernel/kgdb.c               |  25 +---
 arch/x86/kernel/kprobes/core.c       |  19 ++-
 arch/x86/kernel/module.c             |   2 +-
 arch/x86/mm/init_64.c                |  36 +++++
 arch/x86/mm/pageattr.c               |  16 ++-
 arch/x86/xen/mmu_pv.c                |   2 -
 include/asm-generic/tlb.h            |   9 ++
 include/linux/filter.h               |  18 +--
 include/linux/mm.h                   |  18 +--
 include/linux/sched/task.h           |   1 +
 include/linux/set_memory.h           |  11 ++
 include/linux/vmalloc.h              |  15 ++
 init/main.c                          |   3 +
 kernel/bpf/core.c                    |   1 -
 kernel/fork.c                        |  24 +++-
 kernel/module.c                      |  82 ++++++-----
 kernel/power/snapshot.c              |   5 +-
 kernel/trace/bpf_trace.c             |   8 ++
 mm/page_alloc.c                      |   7 +-
 mm/vmalloc.c                         | 113 ++++++++++++---
 31 files changed, 542 insertions(+), 195 deletions(-)

-- 
2.17.1

