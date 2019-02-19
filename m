Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC10AC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43C2A2083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="QDqw8lsp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43C2A2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E37788E0003; Tue, 19 Feb 2019 12:23:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBDED8E0002; Tue, 19 Feb 2019 12:23:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C88408E0003; Tue, 19 Feb 2019 12:23:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6946F8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:23:09 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e14so9237093wrt.12
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:23:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=16mOsQibzOyuKGmlufxdiVA6zEatWjg8A75/MDif08w=;
        b=uODjsgI58slRQAaovu4cs7cEEHMaTOstiDFsQl4VDfQU1uIcP+Xt2PYz5VfIpjrCtJ
         EPyyCVbpuAzHXLYuLUzyUKXxm5AbPKBJyyGYy0+z1MbfVICVWdOQfqYxqInJBXqv2mqb
         /oL76clEw4v6M06RJXdEeCo6ton8WG23wH0qAoQ7A8RY/1gde4afmmu97cRxVlDxRr1j
         v6at5Bm/snbY+gfGV7eTz1ghrTune8vF1+JB5eQ73tf5Qdgs9U7KlHWYd/DulHanVRGA
         +iY1EPtQo/ZSd+542YOxX1Fj0zqgc6VqZcYPqm52j9nNZlZ2U2oxy5ln7kpR4VmZ8Odw
         tiug==
X-Gm-Message-State: AHQUAuZ6JDm/vfn3ndf/oFRyeuZxpBiMVGA7klojl2cElOXb1LugbGNC
	YQ8rVPnFc/4ZgWvMPopc/S5GjEyZmB8qrzmGJrJA8Yqj5OY42ivJaabEnqbyKzixad30d36DqN+
	hWunbJcodvDAvNMOspRR+RmCngXzHBZzZYN8fNpYNrPOJrSlYpMISCmBbC2Q57kfYkw==
X-Received: by 2002:a1c:44c3:: with SMTP id r186mr3679363wma.63.1550596988887;
        Tue, 19 Feb 2019 09:23:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZVKW70lhGjwtkPfBloRmlG0SS3903HXf4W22Moj31Hx4kE++olSQ427eksRZJyoqfvT2bC
X-Received: by 2002:a1c:44c3:: with SMTP id r186mr3679313wma.63.1550596987688;
        Tue, 19 Feb 2019 09:23:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596987; cv=none;
        d=google.com; s=arc-20160816;
        b=xpfGvER3WDP10rr4KNcUg3P7DcuNx85vGMswL3GadkKEI0LgxLxHUg0eELVKkvH/iz
         Sb6JUw2pFpjqz3V8tGMBGUJSS3TuVPEBl7/8bK8DtqMFZUwSyjNWVnfuQ9x3dV2GAYYJ
         AlUvxtD4Qeusj8vjmALS3NeWsA3fwWyYjMC69cO5943EZs9v/it95X5CQxoSBkJ/Rjt7
         MOMf96MCuH43Pivd7hATcNSm4gsHnfBLq/oZXy+x0GQIYMEFns2PUBXZvzBHN1y9yc4J
         b64PWNmaQopbjzpqRIJ4GjAMgXhTjGPCVK6fVafRVz6Q1XgQ2TkzcE7ufWHKkNAD4ICT
         g/nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=16mOsQibzOyuKGmlufxdiVA6zEatWjg8A75/MDif08w=;
        b=bykFt9Z5uWs1FncqYvfta3rem0szkXuQB8Q3OQpZLgXDn4uIPsfRVQ4rfoqQNaCENY
         Vr8TmE5b14Vqv+PvEjkV6O+a9BnRxvtF1jTYL7PKqHWNqIYg2Yz+r/hNh9U0xPp9YhhU
         AV8eUPfrl/sBkoZ3V0avPQzsTA1v96SJzTLYxrsd2zixKRiouIU2vAmTRQ7O/Fd6oCgV
         xGT9Irv1FASePUb+6L9LstoPOui7e4HQALG5gNLAIs71EW3fDuHKSDTT7ApB6iaRvBq/
         CGu4vAUBuIJZf6SzR573x55K0HaNdH00/aENYd1GLDu/AaHZYrIHYl9RtbN++e85eH43
         kHRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=QDqw8lsp;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr ([93.17.236.30])
        by mx.google.com with ESMTPS id n18si1346920wrx.314.2019.02.19.09.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:23:07 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=QDqw8lsp;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443ncn3pcGz9v4wg;
	Tue, 19 Feb 2019 18:23:05 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=QDqw8lsp; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 29MNh-RSs4TH; Tue, 19 Feb 2019 18:23:05 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443ncn25p7z9v4wf;
	Tue, 19 Feb 2019 18:23:05 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550596985; bh=16mOsQibzOyuKGmlufxdiVA6zEatWjg8A75/MDif08w=;
	h=From:Subject:To:Cc:Date:From;
	b=QDqw8lspfArU8pC6Zsu6V60jBblcrtfo1iG1+2NlOLuNtQTgR8aOlUWSvXB03S4hU
	 gTY9fNshHtqw+378+7NQvD/fcPzzOdtD2gSl26Ys9jtiUdO7xLDFkHwIE5HJfKlWEx
	 odOIlDHrl6sUnLVra2hedOP2WelQgsj7/EsEIjqo=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id E29858B7FE;
	Tue, 19 Feb 2019 18:23:06 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id o-2HJ7YHlKai; Tue, 19 Feb 2019 18:23:06 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 94FB78B7F9;
	Tue, 19 Feb 2019 18:23:06 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5FAF96E81D; Tue, 19 Feb 2019 17:23:06 +0000 (UTC)
Message-Id: <cover.1550596242.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v6 0/6] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 19 Feb 2019 17:23:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This serie adds KASAN support to powerpc/32

Tested on nohash/32 (8xx) and book3s/32 (mpc832x ie 603).
Boot tested on qemu mac99

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

For book3s/32 we have to stick to KASAN_MINIMAL because Hash table
management is not active early enough at the time being.

Christophe Leroy (6):
  powerpc/mm: prepare kernel for KAsan on PPC32
  powerpc/32: Move early_init() in a separate file
  powerpc: prepare string/mem functions for KASAN
  powerpc/32: Add KASAN support
  kasan: allow architectures to provide an outline readiness check
  powerpc/32: enable CONFIG_KASAN for book3s hash

 arch/powerpc/Kconfig                          |   1 +
 arch/powerpc/Makefile                         |   9 ++
 arch/powerpc/include/asm/book3s/32/pgtable.h  |   2 +
 arch/powerpc/include/asm/highmem.h            |  10 +-
 arch/powerpc/include/asm/kasan.h              |  51 ++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h  |   2 +
 arch/powerpc/include/asm/setup.h              |   5 +
 arch/powerpc/include/asm/string.h             |  26 +++-
 arch/powerpc/kernel/Makefile                  |  11 +-
 arch/powerpc/kernel/asm-offsets.c             |   4 +
 arch/powerpc/kernel/cputable.c                |  13 +-
 arch/powerpc/kernel/early_32.c                |  36 ++++++
 arch/powerpc/kernel/head_32.S                 |   3 +
 arch/powerpc/kernel/head_40x.S                |   3 +
 arch/powerpc/kernel/head_44x.S                |   3 +
 arch/powerpc/kernel/head_8xx.S                |   3 +
 arch/powerpc/kernel/head_fsl_booke.S          |   3 +
 arch/powerpc/kernel/prom_init_check.sh        |  10 +-
 arch/powerpc/kernel/setup-common.c            |   2 +
 arch/powerpc/kernel/setup_32.c                |  28 -----
 arch/powerpc/lib/Makefile                     |  16 ++-
 arch/powerpc/lib/copy_32.S                    |  13 +-
 arch/powerpc/lib/mem_64.S                     |   8 +-
 arch/powerpc/lib/memcpy_64.S                  |   4 +-
 arch/powerpc/mm/Makefile                      |   1 +
 arch/powerpc/mm/kasan/Makefile                |   5 +
 arch/powerpc/mm/kasan/kasan_init_32.c         | 170 ++++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                         |   4 +
 arch/powerpc/mm/ptdump/dump_linuxpagetables.c |   8 ++
 arch/powerpc/purgatory/Makefile               |   3 +
 arch/powerpc/xmon/Makefile                    |   1 +
 include/linux/kasan.h                         |   4 +
 mm/kasan/generic.c                            |   3 +
 33 files changed, 412 insertions(+), 53 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

-- 
2.13.3

