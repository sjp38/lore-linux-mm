Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33DE4C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6E6721985
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6E6721985
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80DA96B0007; Mon, 22 Jul 2019 11:42:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BFB38E0003; Mon, 22 Jul 2019 11:42:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AE798E0001; Mon, 22 Jul 2019 11:42:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C83A6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z20so26562473edr.15
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=r3kG0u5QV/VGvCumlfyd7rw0Az2AtVGkpUikzEsFTGI=;
        b=Q7oJgoYFvAgMg7r2CHKAWWfX1ZDp7s7NF7fLS+MnlDTqygczLjsl/4jZw4i9TeXeTC
         aFqsssBopEuS9sn1sHbsbRME5jPAigFjlPpFsR6sKDwAgKIaFkpE6OvOFw2VNH7nUe1P
         E7UkfL0hfhRDKzKwnQhLLurIjbRqqcr0C9NW5jC1KOrjGi6bYBLGNhBQZpFZYvA7/SHM
         zbjdi4m5d+EaVe5HWxn0LeEBL3buG1zQLAE59lsyPDjXei5GsfC9/WlaRwpUm/FPQ2Mv
         GTlR8kHge4EZ7FUjF7KYNtK6GpNCWDvSIU+gYF/UAazeEko+nRGjntECqJaQCgHjs+Ly
         2o8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXfmSdJFGw57RqMQfEFN35oLlJlAjg4DFa1lzTRW1eX+5us3aO4
	o9SHFCrvBs77vj4Vtgr4+L/G1NitethBC6ZEo4Ig8mnTJ6bXCl4D4mNMxxwSPTHouArwc1fBzz5
	xCCoqU9A8S2kHEwuRh5xJXqPMTnVpFc83OdjLPAj/RNjP/W9DWfoLO1CIxpVE29jAbA==
X-Received: by 2002:a17:906:40c:: with SMTP id d12mr53010350eja.29.1563810145649;
        Mon, 22 Jul 2019 08:42:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/ey5OhOhXiuYVIXmc47+YQDv8mWksoEirYYsOd7C1QBt29XRoc7gpqEguBdiWckj+cKc5
X-Received: by 2002:a17:906:40c:: with SMTP id d12mr53010294eja.29.1563810144557;
        Mon, 22 Jul 2019 08:42:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810144; cv=none;
        d=google.com; s=arc-20160816;
        b=tUqkZfJKMR6ZAVdmQiLnb5Z1UZ+BlIYwLCXs88aFnfV/KMHXHZjnwWL04bFruZXdX5
         uOq5U6bFrwB496KOXWiyjtoAw/yStppcbZQ0538H4D170dM7hQy4rjzXVATfxiX4fCU7
         xw7hxEvWLvHvLEYRNRDTVaWcBhwIScR3RLsq0U1hf8Flwbuit03q/z0/II1sKVPDgHEg
         eDGgwdcCmQK3rBHUL7Dp8faJcW3VuyUtI8R7YSNPU4AoC3U5WX7lQhvj9lzBRyloMP+z
         hslNa8KvI3YLgHjCHS6iQ8+w1c2XMQR2NIe1yP8aBqQ5HVN157OWLE807Yc8dUaVx796
         AAUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=r3kG0u5QV/VGvCumlfyd7rw0Az2AtVGkpUikzEsFTGI=;
        b=yJvj34aZv9T+UETeLXAsnlTgf597lTic+UB18pITiHSe4/5hle73QJ+wB3vD7EKUPz
         Vl/9K+DDhDPi6SMU6irOLGfj/6/Bgn0NpxJ9aWo1JaLHVdybSmFdh+sfL2mfz/FMDpUa
         0UIh83nUlZXEovtY/Tmz24BYjL8AWElN96byZZrEzUhkkoYRM52V6U2iiEddJkZd/bFL
         nr9YeuyiAN0q2r16bhiq0DAZhyYbf0OXGpC5EWCNshw+XDuI3RXU5BRybN+SIsi27T9u
         u6xxDQ0sfxpcZyq7YxeMZnUrV2nvwly4xw59aT6iLJMIi+ACIN2U84LdW8XC+F6o3ykf
         D7fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id a5si4453581eje.74.2019.07.22.08.42.24
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8591528;
	Mon, 22 Jul 2019 08:42:23 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EE6093F694;
	Mon, 22 Jul 2019 08:42:20 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v9 00/21] Generic page walk and ptdump
Date: Mon, 22 Jul 2019 16:41:49 +0100
Message-Id: <20190722154210.42799-1-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a slight reworking and extension of my previous patch set
(Convert x86 & arm64 to use generic page walk), but I've continued the
version numbering as most of the changes are the same. In particular
this series ends with a generic PTDUMP implemention for arm64 and x86.

Many architectures current have a debugfs file for dumping the kernel
page tables. Currently each architecture has to implement custom
functions for this because the details of walking the page tables used
by the kernel are different between architectures.

This series extends the capabilities of walk_page_range() so that it can
deal with the page tables of the kernel (which have no VMAs and can
contain larger huge pages than exist for user space). A generic PTDUMP
implementation is the implemented making use of the new functionality of
walk_page_range() and finally arm64 and x86 are switch to using it,
removing the custom table walkers.

To enable a generic page table walker to walk the unusual mappings of
the kernel we need to implement a set of functions which let us know
when the walker has reached the leaf entry. After a suggestion from Will
Deacon I've chosen the name p?d_leaf() as this (hopefully) describes
the purpose (and is a new name so has no historic baggage). Some
architectures have p?d_large macros but this is easily confused with
"large pages".

Mostly this is a clean up and there should be very little functional
change. The exceptions are:

* x86 PTDUMP debugfs output no longer display pages which aren't
  present (patch 14).

* arm64 has the ability to efficiently process KASAN pages (which
  previously only x86 implemented). This means that the combination of
  KASAN and DEBUG_WX is now useable.

Also available as a git tree:
git://linux-arm.org/linux-sp.git walk_page_range/v9

Changes since v8:
https://lore.kernel.org/lkml/20190403141627.11664-1-steven.price@arm.com/
 * Rename from p?d_large() to p?d_leaf()
 * Dropped patches migrating arm64/x86 custom walkers to
   walk_page_range() in favour of adding a generic PTDUMP implementation
   and migrating arm64/x86 to that instead.
 * Rebased to v5.3-rc1

Steven Price (21):
  arc: mm: Add p?d_leaf() definitions
  arm: mm: Add p?d_leaf() definitions
  arm64: mm: Add p?d_leaf() definitions
  mips: mm: Add p?d_leaf() definitions
  powerpc: mm: Add p?d_leaf() definitions
  riscv: mm: Add p?d_leaf() definitions
  s390: mm: Add p?d_leaf() definitions
  sparc: mm: Add p?d_leaf() definitions
  x86: mm: Add p?d_leaf() definitions
  mm: Add generic p?d_leaf() macros
  mm: pagewalk: Add p4d_entry() and pgd_entry()
  mm: pagewalk: Allow walking without vma
  mm: pagewalk: Add test_p?d callbacks
  x86: mm: Don't display pages which aren't present in debugfs
  x86: mm: Point to struct seq_file from struct pg_state
  x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
  x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
  x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
  mm: Add generic ptdump
  x86: mm: Convert dump_pagetables to use walk_page_range
  arm64: mm: Convert mm/dump.c to use walk_page_range()

 arch/arc/include/asm/pgtable.h               |   1 +
 arch/arm/include/asm/pgtable-2level.h        |   1 +
 arch/arm/include/asm/pgtable-3level.h        |   1 +
 arch/arm64/Kconfig                           |   1 +
 arch/arm64/Kconfig.debug                     |  19 +-
 arch/arm64/include/asm/pgtable.h             |   2 +
 arch/arm64/include/asm/ptdump.h              |   8 +-
 arch/arm64/mm/Makefile                       |   4 +-
 arch/arm64/mm/dump.c                         | 117 +++----
 arch/arm64/mm/ptdump_debugfs.c               |   2 +-
 arch/mips/include/asm/pgtable-64.h           |   8 +
 arch/powerpc/include/asm/book3s/64/pgtable.h |  30 +-
 arch/riscv/include/asm/pgtable-64.h          |   7 +
 arch/riscv/include/asm/pgtable.h             |   7 +
 arch/s390/include/asm/pgtable.h              |   2 +
 arch/sparc/include/asm/pgtable_64.h          |   2 +
 arch/x86/Kconfig                             |   1 +
 arch/x86/Kconfig.debug                       |  20 +-
 arch/x86/include/asm/pgtable.h               |  10 +-
 arch/x86/mm/Makefile                         |   4 +-
 arch/x86/mm/debug_pagetables.c               |   8 +-
 arch/x86/mm/dump_pagetables.c                | 339 +++++--------------
 arch/x86/platform/efi/efi_32.c               |   2 +-
 arch/x86/platform/efi/efi_64.c               |   4 +-
 drivers/firmware/efi/arm-runtime.c           |   2 +-
 include/asm-generic/pgtable.h                |  19 ++
 include/linux/mm.h                           |  26 +-
 include/linux/ptdump.h                       |  19 ++
 mm/Kconfig.debug                             |  21 ++
 mm/Makefile                                  |   1 +
 mm/pagewalk.c                                |  76 +++--
 mm/ptdump.c                                  | 161 +++++++++
 32 files changed, 507 insertions(+), 418 deletions(-)
 create mode 100644 include/linux/ptdump.h
 create mode 100644 mm/ptdump.c

-- 
2.20.1

