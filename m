Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4072FC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3393206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ocRmO6zU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3393206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45B086B0005; Fri, 26 Apr 2019 12:23:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B78E6B0003; Fri, 26 Apr 2019 12:23:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A8126B0008; Fri, 26 Apr 2019 12:23:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE7B66B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:27 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u18so3899395wrq.2
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=bl/f+UK/BgTKVFOqXdbSbenlcVMsTImDP1UcaQQbtes=;
        b=r8Vq2X+BzKlY4E/SSorkFSaSdT/3JY6+xVMzQgxSoysSD7q6uHX20XxnJLZxnLc/Ia
         4RgeOxg9QH++LxMNY1ofVrmGx80EQT/vGi81SbJl7yhj4/OaT5VDz7QUW0BsYaLEp1j4
         qvVFGkS+/ek5EKHoU0ZMXEXEMVwCO0ONbwJQ2o00ELq4DipMUD+TKtF1cUwSbc2sv02K
         FtUgdCKsdOYIeP1YSrXXuee+tocZqkZfufbvV8csH1dLtBM9VJFzVOBGrsrDEhbrbu0z
         Pvf0sIhVb6LV2MQu3oS9mum2RiSThpRWgTpQQ+5YLL7qOb/uQLC+0pfQwDs2g00Jj81W
         fHqA==
X-Gm-Message-State: APjAAAWYoh02By7Z6N75j58rSONYEAD3ov5e7gMMBdnewHag+3ZgWpVs
	95x736Vks34Bifdtz89GusqcGK51/i1f+2zYXIZ+/cFmYQq1stdhLmz9URMSDtzqChM0MWSyIq8
	BphoDbBDU7wsXxfKXJgsD9xyHg3hLcy/CwXAKtuIYhUIrU0y4AcaeyN74UUrNcF22Tg==
X-Received: by 2002:a05:6000:118a:: with SMTP id g10mr9905910wrx.233.1556295807217;
        Fri, 26 Apr 2019 09:23:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJzcvJ88iT+xPKIbK0DYFjHJ5K3MphD4GkBSbL7KJR56uoxYwTfIvETBQUEleJ6PJrE1W6
X-Received: by 2002:a05:6000:118a:: with SMTP id g10mr9905835wrx.233.1556295806003;
        Fri, 26 Apr 2019 09:23:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295805; cv=none;
        d=google.com; s=arc-20160816;
        b=n2YPA6c+/M1437Dbl88EXKPlEXNeJ5luLyi6hORAQxegCrupolq0EH7zGfSEShb9aN
         dd6canhTwn9oD3oJY0kTGoU+OULfpxAv3N7/o4L6HTJXrZmjglbdumMXj4miWhQC0Gtl
         QPr85ZqpyfFnnjmHLyxnBinPSewE8nvaybBl4y7LTkXxemU2t0hfut+MzArf7sP5IZsR
         JdJH7FFbNaPsDJUXPpvso5h1oL/cxvRe3Ea29Fs1xScXJxbY06nQM3NdlVrFX33lF5Ux
         BaNHyYdcmkohpQgO7xQNBe1e/CX0bWf/DjcstGUj5lFgQNtfti/IrBmzc+EL8eGfVUsP
         rS3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=bl/f+UK/BgTKVFOqXdbSbenlcVMsTImDP1UcaQQbtes=;
        b=yDWOixWR6hkQ48VbJNMGD4FaISBBMC8bfC/4KLX09dx6l82B66Mt4mlIur+FjyRhIH
         0Jj4nKnWaS9GkIkPAXVv45D9IZpoSiy6CoYu3WX7GaVPUSCp2DUMnxBhE9KWcSAPPvJB
         rjsva71RrLic48dRJdFqBMgK1mwiVntDM7v+fhau07O2A6gTYUdSqTjo/0G9/EPMENKF
         1viE3tGPasv9ZHkuGjgPy0rNhsTSoRe7W1EekaqzW7xF/6gbI3O5sj5MMjsnttzPuEZb
         zRD3Fq3HlXOZcvZp7PXZOIy6OnSMOjQsK66ejaYse7tQNUDRZK2fhENV4+oANZsBbuk5
         Lnbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ocRmO6zU;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id v9si1562252wrs.255.2019.04.26.09.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ocRmO6zU;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9R41gNz9v0yb;
	Fri, 26 Apr 2019 18:23:23 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ocRmO6zU; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 1eRi4VVokb8u; Fri, 26 Apr 2019 18:23:23 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9R2j86z9v0t2;
	Fri, 26 Apr 2019 18:23:23 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295803; bh=bl/f+UK/BgTKVFOqXdbSbenlcVMsTImDP1UcaQQbtes=;
	h=From:Subject:To:Cc:Date:From;
	b=ocRmO6zUoj9OSKnggaFk084KqMhuYT3btr4q/5Sam1AYd16iL1CbZ03yvweKHTmuK
	 J8nLW8egw4sfD4FfXgK4ByUNVjEtZQhGpctPzFaw5bg5R5Ln4Pe6+U2/NTAqmnHtve
	 +q31jqMA1sWZkcw/2Q0WenmX3cfJSMOgmehkOgBM=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0AFBB8B950;
	Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 7tnsKQ9-QGc8; Fri, 26 Apr 2019 18:23:24 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D57238B82F;
	Fri, 26 Apr 2019 18:23:24 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 3E994666FE; Fri, 26 Apr 2019 16:23:24 +0000 (UTC)
Message-Id: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 00/13] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series adds KASAN support to powerpc/32

32 bits tested on nohash/32 (8xx), book3s/32 (mpc832x ie 603) and qemu mac99

Changes in v11:
- Dropped book3e RFC part.
- Rebased on latest powerpc merge branch (b251649c77625b7ad4430e518dc0f1608be9edf4).
Main impact is in head_32.S do to the merge with KUAP functionnality
- Added a fix from Daniel in prom_init: changed a direct struct assignation by a memcpy in patch 5

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

Christophe Leroy (13):
  powerpc/32: Move early_init() in a separate file
  powerpc: prepare string/mem functions for KASAN
  powerpc: remove CONFIG_CMDLINE #ifdef mess
  powerpc/prom_init: don't use string functions from lib/
  powerpc: don't use direct assignation during early boot.
  powerpc/32: use memset() instead of memset_io() to zero BSS
  powerpc/32: make KVIRT_TOP dependent on FIXMAP_START
  powerpc/32: prepare shadow area for KASAN
  powerpc: disable KASAN instrumentation on early/critical files.
  powerpc/32: Add KASAN support
  powerpc/32s: move hash code patching out of MMU_init_hw()
  powerpc/32s: set up an early static hash table for KASAN.
  powerpc/32s: map kasan zero shadow with PAGE_READONLY instead of
    PAGE_KERNEL_RO

 arch/powerpc/Kconfig                         |   7 +-
 arch/powerpc/Kconfig.debug                   |   5 +
 arch/powerpc/include/asm/book3s/32/pgtable.h |  13 +-
 arch/powerpc/include/asm/fixmap.h            |   5 +
 arch/powerpc/include/asm/kasan.h             |  40 +++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  13 +-
 arch/powerpc/include/asm/string.h            |  32 +++-
 arch/powerpc/kernel/Makefile                 |  14 +-
 arch/powerpc/kernel/cputable.c               |  13 +-
 arch/powerpc/kernel/early_32.c               |  36 +++++
 arch/powerpc/kernel/head_32.S                |  76 ++++++---
 arch/powerpc/kernel/head_40x.S               |   3 +
 arch/powerpc/kernel/head_44x.S               |   3 +
 arch/powerpc/kernel/head_8xx.S               |   3 +
 arch/powerpc/kernel/head_fsl_booke.S         |   3 +
 arch/powerpc/kernel/prom_init.c              | 228 +++++++++++++++++++++------
 arch/powerpc/kernel/prom_init_check.sh       |  12 +-
 arch/powerpc/kernel/setup-common.c           |   3 +
 arch/powerpc/kernel/setup_32.c               |  28 ----
 arch/powerpc/lib/Makefile                    |  19 ++-
 arch/powerpc/lib/copy_32.S                   |  12 +-
 arch/powerpc/lib/mem_64.S                    |   9 +-
 arch/powerpc/lib/memcpy_64.S                 |   4 +-
 arch/powerpc/mm/Makefile                     |   7 +
 arch/powerpc/mm/init_32.c                    |   3 +
 arch/powerpc/mm/kasan/Makefile               |   5 +
 arch/powerpc/mm/kasan/kasan_init_32.c        | 183 +++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |   4 +
 arch/powerpc/mm/mmu_decl.h                   |   2 +
 arch/powerpc/mm/ppc_mmu_32.c                 |  36 +++--
 arch/powerpc/mm/ptdump/ptdump.c              |   8 +
 arch/powerpc/platforms/powermac/Makefile     |   6 +
 arch/powerpc/purgatory/Makefile              |   3 +
 arch/powerpc/xmon/Makefile                   |   1 +
 34 files changed, 697 insertions(+), 142 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan/Makefile
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c

-- 
2.13.3

