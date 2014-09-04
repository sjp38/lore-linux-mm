Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 16CDF6B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 14:46:09 -0400 (EDT)
Received: by mail-yk0-f169.google.com with SMTP id q200so6412036ykb.0
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 11:46:08 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id q40si13615508yhg.97.2014.09.04.11.46.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 11:46:08 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 0/5] Support Write-Through mapping on x86
Date: Thu,  4 Sep 2014 12:35:34 -0600
Message-Id: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com

This patchset adds support of Write-Through (WT) mapping on x86.
The study below shows that using WT mapping may be useful for
non-volatile memory.

  http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf

This patchset applies on top of the Juergen's patchset below,
which provides the basis of the PAT management.

  https://lkml.org/lkml/2014/8/26/61

All new/modified interfaces have been tested.

---
Toshi Kani (5):
  1/5 x86, mm, pat: Set WT to PA4 slot of PAT MSR
  2/5 x86, mm, pat: Change reserve_memtype() to handle WT
  3/5 x86, mm, asm-gen: Add ioremap_wt() for WT
  4/5 x86, mm: Add set_memory_wt() for WT
  5/5 x86, mm, pat: Add pgprot_writethrough() for WT

---
 arch/x86/include/asm/cacheflush.h    | 10 ++++-
 arch/x86/include/asm/io.h            |  2 +
 arch/x86/include/asm/pgtable_types.h |  3 ++
 arch/x86/mm/ioremap.c                | 24 ++++++++++++
 arch/x86/mm/pageattr.c               | 73 +++++++++++++++++++++++++++++++++---
 arch/x86/mm/pat.c                    | 73 +++++++++++++++++++++++++++---------
 include/asm-generic/io.h             |  4 ++
 include/asm-generic/iomap.h          |  4 ++
 include/asm-generic/pgtable.h        |  4 ++
 9 files changed, 172 insertions(+), 25 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
