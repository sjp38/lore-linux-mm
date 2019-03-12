Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F344EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82114213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="AovvVeWP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82114213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 133E88E0004; Tue, 12 Mar 2019 18:16:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BAB88E0002; Tue, 12 Mar 2019 18:16:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC3838E0004; Tue, 12 Mar 2019 18:16:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 910AA8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:09 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id p7so1598869wrn.20
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=FZQI13aBzWBGnD58d1GdJzG/OYdAntgbNyDCLGhbjQk=;
        b=pcsM6SFhy3DNohKA65PchCqA7e5lhK4MMl8+eoKHx3SQnNvZxZYudvaw8u0b9wqjJU
         1ALHABINKd7HmZ5xwbVz5VCscK0EB6qYdChGzDTmzfuzD39CYjWGTMxMefzok4//jbhr
         nA160eY+ix/8nRv4WV9slcYWp9FIBDtJ2FT4X0VJdmcdxbcYu6mFHi9nG5HcnsKhxR4f
         rwzfjrMFV5HbSs1ND4UxiceBNvIynF1jafvMvgFl3qLm8QNSFRmm/Wky1XumnE/T/oaE
         VPVCVODB792nu263dOIQh1gbCZC8LoLFnY/5SIrZyIbEWlb4AutVhKAt/gJi8FBewSYV
         SK9g==
X-Gm-Message-State: APjAAAVub8m+tIOTKL6TU/ihsYBCiD8E7fNqCmHF7fCZU6I2EF+bD6vC
	qyyozbAq5IVEkg+QgCqMevi9nKu3h+ZqWjCunIGjLq59VHTirtC2xR7tHr3GEX7+Le/uQU1mz2r
	kFt08qoXev04ECdrAa1hfDYifMBK1QfhXZ3KlQ2q2WqNnc2//FvGb9N4feylGQlWHnQ==
X-Received: by 2002:a1c:9ad3:: with SMTP id c202mr15916wme.83.1552428968770;
        Tue, 12 Mar 2019 15:16:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVCvI+rj3/dD+pYMDFJop75KG6jrXsmNKInjJhPYRTK4xHAFv/ogHcOxn4aHDxhUVyOKfl
X-Received: by 2002:a1c:9ad3:: with SMTP id c202mr15865wme.83.1552428967192;
        Tue, 12 Mar 2019 15:16:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428967; cv=none;
        d=google.com; s=arc-20160816;
        b=AXYlTGtTCj7/FSM1PzT4SCOddCneTOTfVeKT2mSFTBMbyRDGKesVqrb8Q3UW4ux6iE
         UWG4Mpjo0HPXmbMwE9eYwWlBpQwY7jfjkPkya0fzqOzzYPG5wuZeWVg1PLHaO0l2Wl7P
         02UZbDsUjecrkfmCghF9IPY+BzCFKWDc2gpUsjXLErOJPSzUopGgvQkA5v4EbyXaxhqE
         lc6BLqbjF7+NXhUFCMUTfLl2JMTRo8Wkpr/6TBh/xCp9EGm5uBqy4861h2kvL8w+Oodb
         f6I4D2EK0A7EDeeG4B7jlkrqtyIjYMc1gWC1goCWU95nkOWZyKUznDE4+NGGsuJgg4eZ
         j1aA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=FZQI13aBzWBGnD58d1GdJzG/OYdAntgbNyDCLGhbjQk=;
        b=MC2h6TLXVFwHohUkPYSu58YizICteI4FK8gP/VIeh9sI7YVXhJbSk33Yc+3hUTDFv9
         UWQ0TkLiNUtbqGg9zrPRy9XoFuywKfPAtShhlgm/2W0ETgdb4ozqs25FBSM9p1EznWlJ
         fEAG79xNn5h02pz7l3YouNfMt4QcXh1mpbaW3hw980LU+ysjNwe+mZ4PCURw/Hwb8D1A
         ZkgQcFLbgAtxRu+PQyQpTSYYaOHRChSIYQMckdnxCsgxSfjJ/vRpQiq7cc/qg1zzZeEl
         ib8QqRH8rlnqtc+vxbXLjbtBXxiFfhRyUg/aKAy3dDj296rUyYAJlGjWiJQrwu2Bd6Qv
         bc5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=AovvVeWP;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l8si18209wmg.93.2019.03.12.15.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=AovvVeWP;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7B3Dnhz9vRb2;
	Tue, 12 Mar 2019 23:16:06 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=AovvVeWP; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id S10DCSwcv3pw; Tue, 12 Mar 2019 23:16:06 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7B1QQWz9vRb0;
	Tue, 12 Mar 2019 23:16:06 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428966; bh=FZQI13aBzWBGnD58d1GdJzG/OYdAntgbNyDCLGhbjQk=;
	h=From:Subject:To:Cc:Date:From;
	b=AovvVeWPlLJAaj672x6zQARu/MwDQwcGeHEV6tDFnHUljJeWGVwYxoZtkjLfChWhg
	 yw/g7+f8DubLMv/Cb6wqbGT+r3+brc41RV8xc8wTIEDI0FV0Mn3Z4V0Er3emWboeCU
	 MAO8Ph0Y2AF/zxaRy/I90KNctSKszH0Q+R9TZzLc=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 66E7A8B8B1;
	Tue, 12 Mar 2019 23:16:06 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id nj8zLmmF5PdK; Tue, 12 Mar 2019 23:16:06 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 275EF8B8A7;
	Tue, 12 Mar 2019 23:16:06 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id B10126FA15; Tue, 12 Mar 2019 22:16:05 +0000 (UTC)
Message-Id: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 00/18] KASAN for powerpc/32 and RFC for 64bit Book3E
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series adds KASAN support to powerpc/32

32 bits tested on nohash/32 (8xx), book3s/32 (mpc832x ie 603) and qemu mac99
64bit Book3E tested by Daniel on e6500

Changes in v10:
- Prepended the patch which fixes boot on hash32
- Reduced ifdef mess related to CONFIG_CMDLINE in prom_init.c
- Fixed strings preparation macros for ppc64 build (Reported by Daniel)
- Fixed boot failure on hash32 when total amount of memory is above the initial amount mapped with BATs.
- Reordered stuff in kasan.h to have a smoother patch when adding 64bit Book3E
- Split the change to PAGE_READONLY out of the hash32 patch.
- Appended Daniel's series for 64bit Book3E (with a build failure fix and a few cosmetic changes)

Changes in v9:
- Fixed fixmap IMMR alignment issue on 8xx with KASAN enabled.
- Set up final shadow page tables before switching to the final hash table on hash32
- Using PAGE_READONLY instead of PAGE_KERNEL_RO on hash32
- Use flash_tlb_kernel_range() instead of flash_tlb_mm() which doesn't work for kernel on some subarches.
- use __set_pte_at() instead of pte_update() to install final page tables

Changes in v8:
- Fixed circular issue between pgtable.h and fixmap.h
- Added missing includes in ppc64 string files
- Fixed kasan string related macro names for ppc64.
- Fixed most checkpatch messages
- build tested on kisskb (http://kisskb.ellerman.id.au/kisskb/head/6e65827de2fe71d21682dafd9084ed2cc6e06d4f/)
- moved CONFIG_KASAN_SHADOW_OFFSET in Kconfig.debug

Changes in v7:
- split in several smaller patches
- prom_init now has its own string functions
- full deactivation of powerpc-optimised string functions when KASAN is active
- shadow area now at a fixed place on very top of kernel virtual space.
- Early static hash table for hash book3s/32.
- Full support of both inline and outline instrumentation for both hash and nohash ppc32
- Earlier full activation of kasan.

Changes in v6:
- Fixed oops on module loading (due to access to RO shadow zero area).
- Added support for hash book3s/32, thanks to Daniel's patch to differ KASAN activation.
- Reworked handling of optimised string functions (dedicated patch for it)
- Reordered some files to ease adding of book3e/64 support.

Changes in v5:
- Added KASAN_SHADOW_OFFSET in Makefile, otherwise we fallback to KASAN_MINIMAL
and some stuff like stack instrumentation is not performed
- Moved calls to kasan_early_init() in head.S because stack instrumentation
in machine_init was performed before the call to kasan_early_init()
- Mapping kasan_early_shadow_page RW in kasan_early_init() and
remaping RO later in kasan_init()
- Allocating a big memblock() for shadow area, falling back to PAGE_SIZE blocks in case of failure.

Changes in v4:
- Comments from Andrey (DISABLE_BRANCH_PROFILING, Activation of reports)
- Proper initialisation of shadow area in kasan_init()
- Panic in case Hash table is required.
- Added comments in patch one to explain why *t = *s becomes memcpy(t, s, ...)
- Call of kasan_init_tags()

Changes in v3:
- Removed the printk() in kasan_early_init() to avoid build failure (see https://github.com/linuxppc/issues/issues/218)
- Added necessary changes in asm/book3s/32/pgtable.h to get it work on powerpc 603 family
- Added a few KASAN_SANITIZE_xxx.o := n to successfully boot on powerpc 603 family

Changes in v2:
- Rebased.
- Using __set_pte_at() to build the early table.
- Worked around and got rid of the patch adding asm/page.h in asm/pgtable-types.h
    ==> might be fixed independently but not needed for this serie.

Christophe Leroy (18):
  powerpc/6xx: fix setup and use of SPRN_SPRG_PGDIR for hash32
  powerpc/32: Move early_init() in a separate file
  powerpc: prepare string/mem functions for KASAN
  powerpc: remove CONFIG_CMDLINE #ifdef mess
  powerpc/prom_init: don't use string functions from lib/
  powerpc/mm: don't use direct assignation during early boot.
  powerpc/32: use memset() instead of memset_io() to zero BSS
  powerpc/32: make KVIRT_TOP dependent on FIXMAP_START
  powerpc/32: prepare shadow area for KASAN
  powerpc: disable KASAN instrumentation on early/critical files.
  powerpc/32: Add KASAN support
  powerpc/32s: move hash code patching out of MMU_init_hw()
  powerpc/32s: set up an early static hash table for KASAN.
  powerpc/32s: map kasan zero shadow with PAGE_READONLY instead of
    PAGE_KERNEL_RO
  kasan: do not open-code addr_has_shadow
  kasan: allow architectures to manage the memory-to-shadow mapping
  kasan: allow architectures to provide an outline readiness check
  powerpc: KASAN for 64bit Book3E

 arch/powerpc/Kconfig                         |   8 +-
 arch/powerpc/Kconfig.debug                   |   5 +
 arch/powerpc/include/asm/book3s/32/pgtable.h |  13 +-
 arch/powerpc/include/asm/fixmap.h            |   5 +
 arch/powerpc/include/asm/kasan.h             | 111 ++++++++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  13 +-
 arch/powerpc/include/asm/string.h            |  32 +++-
 arch/powerpc/kernel/Makefile                 |  14 +-
 arch/powerpc/kernel/cpu_setup_6xx.S          |   3 -
 arch/powerpc/kernel/cputable.c               |  13 +-
 arch/powerpc/kernel/early_32.c               |  36 +++++
 arch/powerpc/kernel/head_32.S                |  52 +++++--
 arch/powerpc/kernel/head_40x.S               |   3 +
 arch/powerpc/kernel/head_44x.S               |   3 +
 arch/powerpc/kernel/head_8xx.S               |   3 +
 arch/powerpc/kernel/head_fsl_booke.S         |   3 +
 arch/powerpc/kernel/prom_init.c              | 218 +++++++++++++++++++++------
 arch/powerpc/kernel/prom_init_check.sh       |  12 +-
 arch/powerpc/kernel/setup-common.c           |   3 +
 arch/powerpc/kernel/setup_32.c               |  28 ----
 arch/powerpc/lib/Makefile                    |  19 ++-
 arch/powerpc/lib/copy_32.S                   |  12 +-
 arch/powerpc/lib/mem_64.S                    |   9 +-
 arch/powerpc/lib/memcpy_64.S                 |   4 +-
 arch/powerpc/mm/Makefile                     |   9 ++
 arch/powerpc/mm/hash_low_32.S                |   8 +-
 arch/powerpc/mm/init_32.c                    |   3 +
 arch/powerpc/mm/kasan/Makefile               |   6 +
 arch/powerpc/mm/kasan/kasan_init_32.c        | 183 ++++++++++++++++++++++
 arch/powerpc/mm/kasan/kasan_init_book3e_64.c |  50 ++++++
 arch/powerpc/mm/mem.c                        |   4 +
 arch/powerpc/mm/mmu_decl.h                   |   2 +
 arch/powerpc/mm/ppc_mmu_32.c                 |  36 +++--
 arch/powerpc/mm/ptdump/ptdump.c              |   8 +
 arch/powerpc/platforms/powermac/Makefile     |   6 +
 arch/powerpc/purgatory/Makefile              |   3 +
 arch/powerpc/xmon/Makefile                   |   1 +
 include/linux/kasan.h                        |   6 +
 mm/kasan/generic.c                           |   6 +-
 mm/kasan/generic_report.c                    |   2 +-
 mm/kasan/kasan.h                             |   6 +-
 mm/kasan/report.c                            |   6 +-
 mm/kasan/tags.c                              |   3 +-
 43 files changed, 829 insertions(+), 141 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_book3e_64.c

-- 
2.13.3

