Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53518C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB28121848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="EY7Xntr4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB28121848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 608878E0004; Tue, 26 Feb 2019 12:22:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B9EE8E0003; Tue, 26 Feb 2019 12:22:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45C618E0004; Tue, 26 Feb 2019 12:22:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8C1A8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:44 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id q126so710418wme.7
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=NT7se+Kk2cpKUAIkvQB8gLiYS7zLHg/DGAXsx/R0Q10=;
        b=HfSaMzRiYBjvYsB2ySwL+FrRo8G5aQtTAai1wW/E3mdPJIDLvEm/E4qvqFfPcgPZMt
         gY2osWdehXSzRiJu0n9xtdv4YZGcNJ5+nq9AVNQaBwVAH4DSvhgq8jDYP7O4afiA67/N
         gHJxRgbgm37mxWpfVDMLb7ICqdD1/pQtOvsN5bZaOIdu54caImuNR9NKiXqgJdmsybI3
         c1w/IBrObIagQG9l1cShi7Bas5+3dwIsEN+m4h38xGdir6OL2I7N8GWDONsZUCjYeIJ/
         DJ0+FD2a/W1+h3AXgSNExZ2WH7lQ6Ec15KibVGxw48hmIMtB+xBwxIr3wdzFXp/zh96l
         Y8RA==
X-Gm-Message-State: AHQUAuZqrr1fPAwDeWoOo7MLrZ4AC/LiPILULKG/2s8zXR3/l8qyJjip
	4lNeutRfl1FCerIVkRAqGIVJ6tz+Xg662pqWnPuWFBuR7o3psSFvls63W5jCowMALxVKYiReH/8
	xfqilXy6hYSUsitgSkD6lu0E/S+jPFSmhkds2rOEVp+S2afOexAFEdU8BMN36xbIW7w==
X-Received: by 2002:adf:a749:: with SMTP id e9mr16489945wrd.210.1551201764229;
        Tue, 26 Feb 2019 09:22:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbUE+1xHV8nXtd56XYSC9DAxbsujKcAO0pcKcHX1sNWDwK5fyUaH4Zhp5imVpOwTDWX7AtO
X-Received: by 2002:adf:a749:: with SMTP id e9mr16489864wrd.210.1551201762740;
        Tue, 26 Feb 2019 09:22:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201762; cv=none;
        d=google.com; s=arc-20160816;
        b=ok7xWPnJgLMKldQ42us7bZxthiCOml0qwO5YRJcn/IWZVoRwm8YTWaq4Vmq+iiUKnT
         salLOoz8jdkRfqyujOBZatO4UTvvKtrvfeQV2bDGeIGDhaWF5pGWgrsf4/GO/zKyTJzl
         AKdKFpKDVV2iSqjb8vEheHzn9q6enxdfldhGna7DcCNpNA6ZBqlh+TGt83qUbtnKEt9m
         xjdv1pVleFhLzQ3evoXToMg8lzXTZHY3d6G6DMNSdRANSCGUmffwcB66+kcn8pRPnkjO
         nMsj36XoRxpXrEGl6fEO9ixVnn3GcGRhXGpGIGazBjfMV57mH3+Daq2ifxEGYllASU+p
         4iUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=NT7se+Kk2cpKUAIkvQB8gLiYS7zLHg/DGAXsx/R0Q10=;
        b=R8UH9KfpRpGhbANh8vLOm1WWMHNeZ3t7k8DXLw9Ux4j6qrxf/gVuprcxkzaf6LEV9a
         ns5D/YqudbuWMTuK1Zo1iCpBZUBmdEX64f0OD8DTKI/cjAfsBsnwFSV3a0xJ7ipkWB4r
         vbXF92tvmjaQGotmOnRPoqAgha6RQMMB6zJF5AvAyiPLiexClmgD3igBFdjmPtE/UCUU
         PxBJTtCGDqqLqJHRBsQOG7MZWYtQen/wlvKo0LPkjU7DhSajv6oCiYd9mFB9ThgfNuc1
         dOxFIW9Fu3g1ch+YcOrTpKdEU46etLbt8NcJYrrKnzVf5wH5Z9sGKdOoV7n4lefL8aXn
         NjvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=EY7Xntr4;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id z62si8496598wmb.139.2019.02.26.09.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:42 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=EY7Xntr4;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485H43yJcz9vJLb;
	Tue, 26 Feb 2019 18:22:40 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=EY7Xntr4; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id N2xyV0G6sBRo; Tue, 26 Feb 2019 18:22:40 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485H42m5Cz9vJLY;
	Tue, 26 Feb 2019 18:22:40 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201760; bh=NT7se+Kk2cpKUAIkvQB8gLiYS7zLHg/DGAXsx/R0Q10=;
	h=From:Subject:To:Cc:Date:From;
	b=EY7Xntr4/B4o17ecsw1D4zkadh+ir3fHlXaOgNZprwxCs90RncpNG+KjglwiVJsji
	 WjUHfcAomwjZnrW/VUmi2tveB5HS+zUfmdJzmUveQwkyH4QEfmI2c6uuOlBASe5+HM
	 AUGEJHh0zJ1MMQasabKPP32IvD/p8/YFwoDLJklU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 061418B97A;
	Tue, 26 Feb 2019 18:22:42 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id X5iYo56s6J5N; Tue, 26 Feb 2019 18:22:41 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A41608B96A;
	Tue, 26 Feb 2019 18:22:41 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5B6F66F7B5; Tue, 26 Feb 2019 17:22:41 +0000 (UTC)
Message-Id: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 00/11] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series adds KASAN support to powerpc/32

Tested on nohash/32 (8xx) and book3s/32 (mpc832x ie 603).
Boot tested on qemu mac99

Changes in v8:
- Fixed circular issue between pgtable.h and fixmap.h
- Added missing includes in ppc64 string files
- Fixed kasan string related macro names for ppc64.
- Fixed most checkpatch messages
- build tested on kisskb (http://kisskb.ellerman.id.au/kisskb/head/6e65827de2fe71d21682dafd9084ed2cc6e06d4f/)

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

Christophe Leroy (11):
  powerpc/32: Move early_init() in a separate file
  powerpc: prepare string/mem functions for KASAN
  powerpc/prom_init: don't use string functions from lib/
  powerpc/mm: don't use direct assignation during early boot.
  powerpc/32: use memset() instead of memset_io() to zero BSS
  powerpc/32: make KVIRT_TOP dependent on FIXMAP_START
  powerpc/32: prepare shadow area for KASAN
  powerpc: disable KASAN instrumentation on early/critical files.
  powerpc/32: Add KASAN support
  powerpc/32s: move hash code patching out of MMU_init_hw()
  powerpc/32s: set up an early static hash table for KASAN.

 arch/powerpc/Kconfig                         |   1 +
 arch/powerpc/Kconfig.debug                   |   5 +
 arch/powerpc/include/asm/book3s/32/pgtable.h |  13 +-
 arch/powerpc/include/asm/fixmap.h            |   5 +
 arch/powerpc/include/asm/kasan.h             |  38 +++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  13 +-
 arch/powerpc/include/asm/string.h            |  32 +++-
 arch/powerpc/kernel/Makefile                 |  14 +-
 arch/powerpc/kernel/cputable.c               |  13 +-
 arch/powerpc/kernel/early_32.c               |  36 +++++
 arch/powerpc/kernel/head_32.S                |  46 ++++--
 arch/powerpc/kernel/head_40x.S               |   3 +
 arch/powerpc/kernel/head_44x.S               |   3 +
 arch/powerpc/kernel/head_8xx.S               |   3 +
 arch/powerpc/kernel/head_fsl_booke.S         |   3 +
 arch/powerpc/kernel/prom_init.c              | 213 +++++++++++++++++++++------
 arch/powerpc/kernel/prom_init_check.sh       |  12 +-
 arch/powerpc/kernel/setup-common.c           |   3 +
 arch/powerpc/kernel/setup_32.c               |  28 ----
 arch/powerpc/lib/Makefile                    |  19 ++-
 arch/powerpc/lib/copy_32.S                   |  15 +-
 arch/powerpc/lib/mem_64.S                    |  11 +-
 arch/powerpc/lib/memcpy_64.S                 |   5 +-
 arch/powerpc/mm/Makefile                     |   7 +
 arch/powerpc/mm/kasan/Makefile               |   5 +
 arch/powerpc/mm/kasan/kasan_init_32.c        | 177 ++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |   4 +
 arch/powerpc/mm/mmu_decl.h                   |   2 +
 arch/powerpc/mm/ppc_mmu_32.c                 |  36 +++--
 arch/powerpc/mm/ptdump/ptdump.c              |   8 +
 arch/powerpc/platforms/powermac/Makefile     |   6 +
 arch/powerpc/purgatory/Makefile              |   3 +
 arch/powerpc/xmon/Makefile                   |   1 +
 33 files changed, 660 insertions(+), 123 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

-- 
2.13.3

