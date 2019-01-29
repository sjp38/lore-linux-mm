Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58E0CC282CF
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1337120870
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1337120870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB21A8E0007; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D71C8E0009; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 729058E000A; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCC08E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s27so12711582pgm.4
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Ol2ArHufJaFLhG5cyfCIpVAxHoPbg+ar0hGWC5WykUI=;
        b=Of1kK6r+exOlJL3rNVRn6A8yGyjoQv2Ua6BucbGPCStAbJvo+UbFt5sJxQHv8/ffb3
         yPhmCDERYkH4753oy/J3NsTnOgPaMocE36Qk636aaa1+Mck385cYxRGv5rzFTzWIZ+xD
         BdSQ1GYyt/5LU9I89mTLK6qwwuxoc0r9YSnfS2OEtfY2O+uuNlYIYi32YrSaPXeq9Gz2
         SivID2s7Bu2TiDgbevcK57ZAQGy8UmLin1uEXZpbi4ILbAJm0TDf12uXoyCaAE2SMbH9
         kvixHCIR3Ky4WHdcCd1k9PveAku47/u9xV+KW90gJg/xvZypg9T/vWKbfJcotM4CSQpr
         OBtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdFCyVJoz5tiJ5kHLjLewU4QifacWHXWCzK81XlXWsnj+LXvniJ
	nXyre4oJePVzTpi4+jVJ7GVLvsII/c9fDPH5Crh/MnLWLOykXGZrA5sfrt3pE2LMK6jIPLcIqoC
	asXpPUkQBsrGKLKKs3UKGZ6Fd3+sUeE1HW5mInEZIxQwZYlk5paOBm4CeUZ8WBJWE5w==
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr24213879plb.26.1548722353288;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7En9fg3Ancx/vA0NAq9wJMzo/dPykyyIWRKQXKD8heGT3v6xW+n/dRJ6A4sIdq28RStBdz
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr24213821plb.26.1548722352157;
        Mon, 28 Jan 2019 16:39:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722352; cv=none;
        d=google.com; s=arc-20160816;
        b=Zp3O6alO12nXAaZO51jvw10Q/sGNaan+LtETdOxU5K9TO1hPXkPsD7NeUl3fJl5nZp
         a2Vo/uJfW/Hh9MaWWEQoMrJU9rRFaVwAPibrZWsw0mcw5jsMaKYNXsftvhfV41nmDWhg
         8Nij/XabcxwIbAmzIgJmKH6D73kmqITYozJT3PiSm9SUdKkPOgW0mfJAggnFMAJqkvTr
         0x+nfQQ4xnIFqsGrw5l4jPuLkr9jBIjYHynCxCPcpi20+Yvztb+IAMVPP4xx+I/ij+XE
         OOBnQrZG/RvHqem7yUL0bBPZheA4aUdVyCILgRIO0MsGEXjO2UpC5PmrVORAChD2ksRm
         WS+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Ol2ArHufJaFLhG5cyfCIpVAxHoPbg+ar0hGWC5WykUI=;
        b=WIlq26+TN69ADDeDQngFE43jvJvBuELIGMmQJRQd6HS9zspZKtPy1EVpW5Drok+1ta
         4KIp9MNYQ33KNISOC5zF+wBHkQFnxTuonMnjdGy021iuLKgYd1c5uarcj0DOvNcV8Gis
         w5Y8mLfpXaWoaIHM37IhMU3sKFPh9C3Z6ClLJ0941K6A+rB1n7yptjXH3mvF0ohZLvaO
         TW9zzP0S6RFHICO1CSDvxIANWxa0WlfvTNw0lqNqDF8rv6JcHWtwypZVn+ltZnBlSmWV
         uv/Nbl35184LQN1gqSPY671a9RO+m4ivdIKagkiVyq5m4XjCycEFavw9XgReMe/rgVWm
         r9ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l7si33052569pfg.245.2019.01.28.16.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921882"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:10 -0800
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
Subject: [PATCH v2 00/20] Merge text_poke fixes and executable lockdowns
Date: Mon, 28 Jan 2019 16:34:02 -0800
Message-Id: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset improves several overlapping issues around stale TLB
entries and W^X violations. It is combined from a slightly tweaked
"x86/alternative: text_poke() enhancements v7" [1] and a next version of
the "Don’t leave executable TLB entries to freed pages v2" [2]
patchsets that were conflicting.

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

Changes for v2:
 - Adding “Reviewed-by tag” [Masami]
 - Comment instead of code to warn against module removal while patching [Masami]
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
  x86/mm: temporary mm struct

Nadav Amit (12):
  Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
  x86/jump_label: Use text_poke_early() during early init
  fork: provide a function for copying init_mm
  x86/alternative: initializing temporary mm for patching
  x86/alternative: use temporary mm for text poking
  x86/kgdb: avoid redundant comparison of patched code
  x86/ftrace: set trampoline pages as executable
  x86/kprobes: instruction pages initialization enhancements
  x86: avoid W^X being broken during modules loading
  x86/jump-label: remove support for custom poker
  x86/alternative: Remove the return value of text_poke_*()
  x86/alternative: comment about module removal races

Rick Edgecombe (7):
  Add set_alias_ function and x86 implementation
  mm: Make hibernate handle unmapped pages
  vmalloc: New flags for safe vfree on special perms
  modules: Use vmalloc special flag
  bpf: Use vmalloc special flag
  x86/ftrace: Use vmalloc special flag
  x86/kprobes: Use vmalloc special flag

 arch/Kconfig                         |   4 +
 arch/x86/Kconfig                     |   1 +
 arch/x86/include/asm/fixmap.h        |   2 -
 arch/x86/include/asm/mmu_context.h   |  32 +++++
 arch/x86/include/asm/pgtable.h       |   3 +
 arch/x86/include/asm/set_memory.h    |   3 +
 arch/x86/include/asm/text-patching.h |   7 +-
 arch/x86/kernel/alternative.c        | 199 ++++++++++++++++++++-------
 arch/x86/kernel/ftrace.c             |  14 +-
 arch/x86/kernel/jump_label.c         |  19 ++-
 arch/x86/kernel/kgdb.c               |  25 +---
 arch/x86/kernel/kprobes/core.c       |  19 ++-
 arch/x86/kernel/module.c             |   2 +-
 arch/x86/mm/init_64.c                |  36 +++++
 arch/x86/mm/pageattr.c               |  16 ++-
 arch/x86/xen/mmu_pv.c                |   2 -
 include/linux/filter.h               |  18 +--
 include/linux/mm.h                   |  18 +--
 include/linux/sched/task.h           |   1 +
 include/linux/set_memory.h           |  10 ++
 include/linux/vmalloc.h              |  13 ++
 init/main.c                          |   3 +
 kernel/bpf/core.c                    |   1 -
 kernel/fork.c                        |  24 +++-
 kernel/module.c                      |  82 ++++++-----
 mm/page_alloc.c                      |   7 +-
 mm/vmalloc.c                         | 122 +++++++++++++---
 27 files changed, 494 insertions(+), 189 deletions(-)

-- 
2.17.1

