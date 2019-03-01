Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E143C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B014B20850
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="UHeQUJTw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B014B20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B3B48E0003; Fri,  1 Mar 2019 07:33:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 536978E0001; Fri,  1 Mar 2019 07:33:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D9588E0004; Fri,  1 Mar 2019 07:33:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7B9C8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:41 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id p4so4732607wmc.8
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=7oN6T50rWTx5tWzMQ79H6gTo5wa3nwlj65g82dpWG0Q=;
        b=r7A5SbRCDP3ilv7n5JcPK/XtvvXRXqGwi9nlEwRhcN3vKWScyY2V+BZ1PQ3oXQUwpj
         FQfg3MeRkMR5tSY6LITq4VoHSGOkm4ft/+/meiNwNqb3xEzeEp1EMvw8qFEa0soo9b+m
         27Rbk93ULeVhqhu72KivACeQvvlWSxoK+oQduUKeE9hH5MypVK4PJ3MpU63PXhoHR9yQ
         AVoNlrLq4JEe/jIBh2t1GY7zOZE3hU19gPCJO+aNrs53a6r/2AQF5IGdww5SuBzdGTNz
         UEf/dNqPN0TAuEP3kjFI3WnvYyAW/YiV+QEfShlWedne2vBPB1fhWiz2PR1Mr0F1q3N/
         bKmw==
X-Gm-Message-State: APjAAAUpjWLdyossYEiub35Nr5bY0k1OXQJejUCW5CQhZ9t+OK4o7y6Q
	OGZy495jQ61QOPCdAAbBcc+Qd/YbDS8lY31R2EOB8K6mTk4Qj21Oa3obsQVN0EGBbbmdbmymd/5
	J+Q94E/uTV9Be1pB71LDMn/W4osOm0csV3dfuJwQzVYVCZi1elVWkqsmEAhcL7oZhng==
X-Received: by 2002:a5d:6446:: with SMTP id d6mr3409895wrw.72.1551443621374;
        Fri, 01 Mar 2019 04:33:41 -0800 (PST)
X-Google-Smtp-Source: APXvYqz87fnzV+H0AA1iYjxhpCrDXrh+7F+Its6+tcdw361BeAcen7vOzEQuJLHv2buTssbrYFNd
X-Received: by 2002:a5d:6446:: with SMTP id d6mr3409803wrw.72.1551443619603;
        Fri, 01 Mar 2019 04:33:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443619; cv=none;
        d=google.com; s=arc-20160816;
        b=yNCrc47asV/nuJNJttR3yHH5e8ZibMM7KZhl9w8EMTIsHgkQqdpJ74ynN6aDS3IrXV
         JBaGBDAndU4N5p3luR7cjMqZIL82heTz/2eJkLZq0ofgzy9hn+hthDXQa6oCLuO9ASOF
         FjjeGqQm7faNUE+NjmNUnLBzWZhWfUntz01iTpccEfHRsZWjs1aoNRfLANjWfXsdqPhK
         yyEMiR1KiZpbpLYhkhwySO7zRlTY1lFIRREYeniBjjwuHhq5jklglmI2TJV2W/Rz9J3V
         7kmHWIFRGeOVgRbow8L0EBffdzOsV70dot62Qw3I35rDl6VaW0vtEMgXQR4FNGlwqIPD
         cIdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=7oN6T50rWTx5tWzMQ79H6gTo5wa3nwlj65g82dpWG0Q=;
        b=o9XPcW8hARKuNIMdoou+ILTLw5s8y4U+WvXflMZipW+5Rn0Ko85kO+hPeiTuN3zCtq
         hTctEZsqkJ9L/DrRkXdu8WBupiZvt1Ok+8bYENem2HJh/P2BGxiT2GbpyDWUt5tNNFaV
         x5nnlRbCg/dlOlp0sgl3/8hi4ZmjnuuNz0zP07DWAonKHpYOJ7NTpzOg/kUMRWd0pqSG
         h/Qf52H11hfCovosTIu2mpaW6i3etOuMxkYXtVu6zdHyBdgnsPl2rNMAX+orIO71wQ6H
         /mWvElcz03mThDJ1SxWtUaxJA3QAxlsQQd8j8fY8fXpzb9pZZv6udj6eW9PhwG1fUkBy
         6UmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UHeQUJTw;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id q16si13577773wrr.21.2019.03.01.04.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:39 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UHeQUJTw;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pk953SNz9txrj;
	Fri,  1 Mar 2019 13:33:37 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=UHeQUJTw; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id PJMPROYOk96p; Fri,  1 Mar 2019 13:33:37 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pk93p0Tz9txrh;
	Fri,  1 Mar 2019 13:33:37 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443617; bh=7oN6T50rWTx5tWzMQ79H6gTo5wa3nwlj65g82dpWG0Q=;
	h=From:Subject:To:Cc:Date:From;
	b=UHeQUJTw7j8ftFEiVzHlepMpc6Ekpc3kI710G19+VAPMLz0oxxxcMGKxNkjgADD1Q
	 7U0iP8LkdYOmft4/yF+01iWSLIyYoLulWEr6KtMDgBk9PYeRIiIQ+tV5KLhLC9uGeZ
	 b4TrK1CHo5nN3dB/VIr9cDAubW47KmHgYbxyr6y4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C9A128BB8B;
	Fri,  1 Mar 2019 13:33:38 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 8AogqSspbLOx; Fri,  1 Mar 2019 13:33:38 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 684B58BB73;
	Fri,  1 Mar 2019 13:33:38 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 2B9396F89E; Fri,  1 Mar 2019 12:33:38 +0000 (UTC)
Message-Id: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 00/11] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series adds KASAN support to powerpc/32

Tested on nohash/32 (8xx) and book3s/32 (mpc832x ie 603).
Boot tested on qemu mac99

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
 arch/powerpc/include/asm/kasan.h             |  39 +++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  13 +-
 arch/powerpc/include/asm/string.h            |  32 +++-
 arch/powerpc/kernel/Makefile                 |  14 +-
 arch/powerpc/kernel/cputable.c               |  13 +-
 arch/powerpc/kernel/early_32.c               |  36 +++++
 arch/powerpc/kernel/head_32.S                |  49 ++++--
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
 arch/powerpc/mm/kasan/kasan_init_32.c        | 189 ++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |   4 +
 arch/powerpc/mm/mmu_decl.h                   |   2 +
 arch/powerpc/mm/ppc_mmu_32.c                 |  36 +++--
 arch/powerpc/mm/ptdump/ptdump.c              |   8 +
 arch/powerpc/platforms/powermac/Makefile     |   6 +
 arch/powerpc/purgatory/Makefile              |   3 +
 arch/powerpc/xmon/Makefile                   |   1 +
 33 files changed, 676 insertions(+), 123 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

-- 
2.13.3

