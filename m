Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0938EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4350B20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="RgxNuD2D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4350B20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDEBC8E00FD; Mon, 25 Feb 2019 08:48:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8E768E000C; Mon, 25 Feb 2019 08:48:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA3948E00FD; Mon, 25 Feb 2019 08:48:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 662C88E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:38 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id z13so4853554wrp.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=MVl4Uuz0Q0Ct5tPndvP+CTSwLp9vJb9UC6aIVeNIuZk=;
        b=JX+FRm4+kk19OexKhZfKmEFNLoCLRcYSUe4KfR/tnGsa9suornnfPLeam6rv2Q5A94
         C/2lABGaOhwqxEda5DPqvH8nH0yY9fS1AI7Sx5L1GO8b1Nz/6gzAhWcRNqZIa5bTj1RP
         JqS2ZJaRzloiCvSN08EqQzMFMmlGs4Bm5+WT7J7WbIorVAcffTgiibd/M1Vwf6OH5wBl
         qtSDxnG9AanBjlT9S77lRAJJzB0U+MnllbaOXxuE/+5H/7OWcqZHZwxCX+CRcRQpRHWs
         zduCTnE3xTNh/AL5MFcBnfGOV+fyGXmq6UZiTGxqRduYMvrA3bTRVRN+Ai0SUcyHyyAR
         hJNA==
X-Gm-Message-State: AHQUAuYw3uyiRr6gq7LBobJrAalmdD0m6SJzDX+3dWNuxcD21CF2o0p9
	8Wd1fHcTwKB2XcO5lRfZBamvOHpByMzCHcFFfjn0pTRKkgl+fbA13NqAY39/E1k90GlyzB7chzk
	Dq5/d9XI11w9VLNeo9zSdQTAf7kdTVSA+bxlqVTk1/Klu2lnhORpw1jpaeIy6jmHPBA==
X-Received: by 2002:a7b:c4cb:: with SMTP id g11mr4065111wmk.84.1551102517728;
        Mon, 25 Feb 2019 05:48:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IawbuVVeZRtrW4exM0bGrPGWrwm136JIIzUYZWqFDdbqeoRY4CPtX5qf0NH7Y9gpI9hOjr8
X-Received: by 2002:a7b:c4cb:: with SMTP id g11mr4065063wmk.84.1551102516540;
        Mon, 25 Feb 2019 05:48:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102516; cv=none;
        d=google.com; s=arc-20160816;
        b=vcyYC++xyN4jK1rTErK1QOlC4NJlXmVi3WdVHc7NPDkJz3G2PMfkdSJyfZ9FJDBp4j
         Nbs3Mhn0rjfwo7/IIcbykLnonzPcyw65c1bRt10QF5him21Vrw2ZnERJMUmXKO17dfZ9
         K3Eb33CuojPi7nDOSiyViPki3WFXkN2kQQAl81s+vtgIVlOUJNyivNPd3IyqrOkF/DOT
         jjv81Nj0pKwn2aKslJL3z+GYTELwP2HIzaRxce3gF01aYO8lSThiVPidr6YK/OqmgcXB
         /55gulystptnfaHlrT8wmMtSFgg7RRuagYq9hfwvhOYKTzxOlimyxhJv1OXMlIEuLlEE
         1fNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=MVl4Uuz0Q0Ct5tPndvP+CTSwLp9vJb9UC6aIVeNIuZk=;
        b=Vq/k4D4XMIYBKvD6CbHqRobY5bnJILivgZNFfPOTpiI9raMbGsKb2UsV2HI84s1YwG
         pjJ6BUTNY5yJXgJ3oE/hrOhuI1RSyEI+R6gRRUSJWGadLoqJcNfty/4XPJJfbACh9Te8
         q5J33iIPkTf2MtFLGh19h6D9Y92w6VU2K0nJc1RIyJkA0hOLeXh03owvE49WUFgPpRSX
         u9Utc1SumHp3zHZOW6yjtW74qiXiaLx9hnIHfAEmAiQ93p2P9gr19tr77d8uUMp1aDLd
         de1qrb5VjooYZcVaR/xYrU4j+Lnq+qtTXoGQ6U18+nE36Lpt5WuZ2FJRApSIIsMebRIu
         tZqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RgxNuD2D;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id y8si6076806wrp.254.2019.02.25.05.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:36 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RgxNuD2D;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZQ72CPzB09Zp;
	Mon, 25 Feb 2019 14:48:30 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=RgxNuD2D; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id l8Y9FFZEQK7W; Mon, 25 Feb 2019 14:48:30 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZQ5mr9zB09Zn;
	Mon, 25 Feb 2019 14:48:30 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102510; bh=MVl4Uuz0Q0Ct5tPndvP+CTSwLp9vJb9UC6aIVeNIuZk=;
	h=From:Subject:To:Cc:Date:From;
	b=RgxNuD2DQ9JcxU789XmAy6kJmEfV1+5moSrWKVVM2pNi8Eb/e/U6MpssZcMpZJXxb
	 Rjng5hsV9ki06eAOyW0NkGR1H9/yHACnNmTVidods/D620FhaGCwjyL1dAaKG3+uyD
	 FQSUKtmK1pn3We2GQTYvIErlTWZ3q0CNbSDAIMgE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 27A498B844;
	Mon, 25 Feb 2019 14:48:35 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id V5LYI8tcdbaW; Mon, 25 Feb 2019 14:48:35 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id EE1378B81D;
	Mon, 25 Feb 2019 14:48:34 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5577F6F20E; Mon, 25 Feb 2019 13:48:35 +0000 (UTC)
Message-Id: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 00/11] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series adds KASAN support to powerpc/32

Tested on nohash/32 (8xx) and book3s/32 (mpc832x ie 603).
Boot tested on qemu mac99

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
  powerpc/32: make KVIRT_TOP dependant on FIXMAP_START
  powerpc/32: prepare shadow area for KASAN
  powerpc: disable KASAN instrumentation on early/critical files.
  powerpc/32: Add KASAN support
  powerpc/32s: move hash code patching out of MMU_init_hw()
  powerpc/32s: set up an early static hash table for KASAN.

 arch/powerpc/Kconfig                         |   6 +
 arch/powerpc/include/asm/book3s/32/pgtable.h |   2 +-
 arch/powerpc/include/asm/fixmap.h            |   5 +
 arch/powerpc/include/asm/kasan.h             |  39 +++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |   2 +-
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
 arch/powerpc/lib/mem_64.S                    |  10 +-
 arch/powerpc/lib/memcpy_64.S                 |   4 +-
 arch/powerpc/mm/Makefile                     |   7 +
 arch/powerpc/mm/init_32.c                    |   1 +
 arch/powerpc/mm/kasan/Makefile               |   5 +
 arch/powerpc/mm/kasan/kasan_init_32.c        | 177 ++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |   4 +
 arch/powerpc/mm/mmu_decl.h                   |   2 +
 arch/powerpc/mm/ppc_mmu_32.c                 |  34 +++--
 arch/powerpc/mm/ptdump/ptdump.c              |   8 +
 arch/powerpc/platforms/powermac/Makefile     |   6 +
 arch/powerpc/purgatory/Makefile              |   3 +
 arch/powerpc/xmon/Makefile                   |   1 +
 33 files changed, 640 insertions(+), 119 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

-- 
2.13.3

