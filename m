Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC15AC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:36:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 587922184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:36:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="p2HcFkRS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 587922184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAB508E0012; Tue, 12 Feb 2019 08:36:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C34168E0011; Tue, 12 Feb 2019 08:36:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFBA78E0012; Tue, 12 Feb 2019 08:36:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 598248E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:36:53 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id l5so1024755wrv.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:36:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=poil0vqGFXHMeWd6QywaPEIOxEm2SJqoaaLYSbpclOc=;
        b=aOKhngb7Fedgokwe8W6fKmVJvN5nIi/a20yacwV5ihd8SeuOsrkMWi7iWPA69tpUWT
         Z6fUyUGdKlkOV7FCYQGi+49CZaVHkbUVhZxRYCyRoR9Xim9T1GuthC9T9ddrdSBC7enf
         7qYY8N9k1b8kDDi6n7Qexl+wMV1ucQEmAqR2ACoqwvMxw2sPoBEeX3gg24EfPZBe/gik
         0U81wtGGokVLrfkAW+jHGofUTXYkSFqBAyHppU8lKso2b680OQ5VPC6eBeMJ4UFDyZZQ
         n2n8JnFfrU56HbNpROPb9aACrJQ9FK7ZsFjVj6viIuMKFMmesxF0CZ84m9S0aMJeaF2B
         k5fg==
X-Gm-Message-State: AHQUAuZvephk3VdrtzVRmlqiVh1GfQCieZEYidf436EHW9gX1D4jRohe
	7X1dpHCN9h72HiNhhCIBxYJ7f85aKoEYOhiESWfVZ6hd6MJZn6URzS6Gxq0Al8MMtVUtriJ8F6q
	NXW38aeV6bU4U1BCBXQPfHXzifSMnN8wDi8hwpb1SIK0LPeSrbztR8I8XeI1xhQ6k+Q==
X-Received: by 2002:a1c:ed17:: with SMTP id l23mr2999955wmh.51.1549978612807;
        Tue, 12 Feb 2019 05:36:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IawDCgjE9ANBoF7LLYXCH7DTDjPyeT1PzLv/WiXDYNvbZGPdKosly8TB0/fiVrOdui2Ruj7
X-Received: by 2002:a1c:ed17:: with SMTP id l23mr2999897wmh.51.1549978611721;
        Tue, 12 Feb 2019 05:36:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549978611; cv=none;
        d=google.com; s=arc-20160816;
        b=IiTmz3K/+I+xng1jx/1ozIh3P4EkouC5+bfGz53aEXbCMKPPkYWIpj4UK42OYQetOH
         TEkzKKms68AkaguBc9bH781A7k27456tSi4BCR9e9dX2KpGiVwPE6vnq0Bh5+NL164vw
         8pqsQjgnoIiv2L8KwviWYgQmwYX0AbCcrIWBofXVcE2dnbDEfxzxygxC1ERGeI7C3mMS
         2+ioPyY/APuylETWIjPL6WmoELiTBxhg+9FGn/ppmruNYhFYCLPz0yVxFUzGyzvO6Xbj
         JEc0cnuSur3F8iP8X5eMQVCyOSK8CppuE9jFOCMUquwVVkkCbz9lquXJzAzijWuPPILf
         MkPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=poil0vqGFXHMeWd6QywaPEIOxEm2SJqoaaLYSbpclOc=;
        b=ni3ECFa0cOSn91yMfmKqA0tZGN7ayKie+vGBVNwTGyUYxJp6EiFlnUNRpHmnxhNasW
         GZkiI3tMuggwsvSHdwh4MAnvoV9+917gCSUEeSW2xM65hmtXqDv+fvT4o9akSP/S8MRv
         r4ChEfjAco0vLd1Ph1y2iUyCzoJ3I4fef3vvrq8J38ZyacdMy29HGx6IpGb7gs5J7g67
         MmrVQS+RkAwDAKLH3jEoM3dWPeIWrcNWWq9ELh5gb9YPZXlAbl8UC7tQk6WGBpfrdak+
         JtG54dNQktGL30LrCq6MiCyZ5tiXu09fCIvwPf011NgLnKUqBTMawThIUg/ilvnFFAdt
         km9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=p2HcFkRS;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id f10si1652222wmf.34.2019.02.12.05.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 05:36:51 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=p2HcFkRS;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43zNwx57DVz9v1GB;
	Tue, 12 Feb 2019 14:36:49 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=p2HcFkRS; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id dOOiq_ebMMnF; Tue, 12 Feb 2019 14:36:49 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43zNwx419jz9v1G9;
	Tue, 12 Feb 2019 14:36:49 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1549978609; bh=poil0vqGFXHMeWd6QywaPEIOxEm2SJqoaaLYSbpclOc=;
	h=From:Subject:To:Cc:Date:From;
	b=p2HcFkRSYO2MZD+VFVI+KhHPjT48msOjR6C4LL7d2eNvN2iBmS9plCVBX01eOgq3h
	 Npgx7f8mA0/UIjYXF4skHXztZ2wqAVReyfir5p8JzWae4J9lUxNWSwBXka+SR6sa+C
	 Iyf5t1PJpZrDdHpVPi/9mZ4f+9nOv+/A5m8Mp3oU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id DFD6A8B7F9;
	Tue, 12 Feb 2019 14:36:50 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id pPOArjaDN3Kj; Tue, 12 Feb 2019 14:36:50 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 94D588B7EB;
	Tue, 12 Feb 2019 14:36:50 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5657B6899C; Tue, 12 Feb 2019 13:36:50 +0000 (UTC)
Message-Id: <cover.1549935247.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v5 0/3] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Feb 2019 13:36:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This serie adds KASAN support to powerpc/32

Tested on nohash/32 (8xx) and book3s/32 (mpc832x ie 603)

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

For book3s/32 (not 603), it cannot work as is because due to HASHPTE flag, we
can't use the same pagetable for several PGD entries, and because Hash table
management is not not active early enough at the time being.

Christophe Leroy (3):
  powerpc/mm: prepare kernel for KAsan on PPC32
  powerpc/32: Move early_init() in a separate file
  powerpc/32: Add KASAN support

 arch/powerpc/Kconfig                         |   1 +
 arch/powerpc/Makefile                        |   7 ++
 arch/powerpc/include/asm/book3s/32/pgtable.h |   2 +
 arch/powerpc/include/asm/kasan.h             |  24 ++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |   2 +
 arch/powerpc/include/asm/ppc_asm.h           |   4 +
 arch/powerpc/include/asm/setup.h             |   5 ++
 arch/powerpc/include/asm/string.h            |  14 ++++
 arch/powerpc/kernel/Makefile                 |  11 ++-
 arch/powerpc/kernel/asm-offsets.c            |   4 +
 arch/powerpc/kernel/cputable.c               |  13 ++-
 arch/powerpc/kernel/early_32.c               |  35 ++++++++
 arch/powerpc/kernel/head_32.S                |   3 +
 arch/powerpc/kernel/head_40x.S               |   3 +
 arch/powerpc/kernel/head_44x.S               |   3 +
 arch/powerpc/kernel/head_8xx.S               |   3 +
 arch/powerpc/kernel/head_fsl_booke.S         |   3 +
 arch/powerpc/kernel/prom_init_check.sh       |  10 ++-
 arch/powerpc/kernel/setup-common.c           |   2 +
 arch/powerpc/kernel/setup_32.c               |  28 -------
 arch/powerpc/lib/Makefile                    |   8 ++
 arch/powerpc/lib/copy_32.S                   |   9 ++-
 arch/powerpc/mm/Makefile                     |   3 +
 arch/powerpc/mm/dump_linuxpagetables.c       |   8 ++
 arch/powerpc/mm/kasan_init.c                 | 114 +++++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |   4 +
 26 files changed, 285 insertions(+), 38 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan_init.c

-- 
2.13.3

