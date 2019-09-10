Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94750C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 320A120872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Uo7vBuqs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 320A120872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3BA66B0007; Tue, 10 Sep 2019 05:17:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEDBB6B0008; Tue, 10 Sep 2019 05:17:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C021D6B000A; Tue, 10 Sep 2019 05:17:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEE56B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:16 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 519CC181AC9BF
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:16 +0000 (UTC)
X-FDA: 75918457272.10.fold96_532c6fefd511
X-HE-Tag: fold96_532c6fefd511
X-Filterd-Recvd-Size: 4680
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:15 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDS719hz9txW0;
	Tue, 10 Sep 2019 11:17:12 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Uo7vBuqs; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id aiL9FREYs1Iv; Tue, 10 Sep 2019 11:17:12 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDS5yLgz9txVx;
	Tue, 10 Sep 2019 11:17:12 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107032; bh=W7DK9fV7ou1Pj1g9DnumvyDlGuhYJdM1G0uUAoFgmVY=;
	h=From:Subject:To:Cc:Date:From;
	b=Uo7vBuqsQYCrMwrHXVGWzbOzqvISk+RBR+kV0zI1xyLyEpyh5cXME5zC/2O25DQqA
	 puotdR6/Dn7foKcZ9Pd/6FHOUF/aAc5b8HUi0v5XMr1aeZw8w7cffZV/QoLBUgA7TS
	 kRXPM+mpk8wzDRiGC/YuAvZQ08R+3NEgkmXVNilE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 02D958B877;
	Tue, 10 Sep 2019 11:17:13 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Nni7Vn_UJZAF; Tue, 10 Sep 2019 11:17:12 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8D2A58B885;
	Tue, 10 Sep 2019 11:16:19 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 16AA46B739; Tue, 10 Sep 2019 09:16:18 +0000 (UTC)
Message-Id: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 00/15] Enable CONFIG_VMAP_STACK on PPC32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The purpose of this serie is to enable CONFIG_VMAP_STACK on PPC32.

rfc v1: initial support on 8xx

rfc v2: added stack overflow detection.

v3:
- Stack overflow detection works, tested with LKDTM STACK_EXHAUST test
- Support for book3s32 added

Christophe Leroy (15):
  powerpc/32: replace MTMSRD() by mtmsr
  powerpc/32: Add EXCEPTION_PROLOG_0 in head_32.h
  powerpc/32: save DEAR/DAR before calling handle_page_fault
  powerpc/32: move MSR_PR test into EXCEPTION_PROLOG_0
  powerpc/32: add a macro to get and/or save DAR and DSISR on stack.
  powerpc/32: prepare for CONFIG_VMAP_STACK
  powerpc: align stack to 2 * THREAD_SIZE with VMAP_STACK
  powerpc/32: Add early stack overflow detection with VMAP stack.
  powerpc/8xx: Use alternative scratch registers in DTLB miss handler
  powerpc/8xx: drop exception entries for non-existing exceptions
  powerpc/8xx: move DataStoreTLBMiss perf handler
  powerpc/8xx: split breakpoint exception
  powerpc/8xx: Enable CONFIG_VMAP_STACK
  powerpc/32s: reorganise DSI handler.
  powerpc/32s: Activate CONFIG_VMAP_STACK

 arch/powerpc/include/asm/irq.h         |   1 +
 arch/powerpc/include/asm/processor.h   |   6 ++
 arch/powerpc/include/asm/thread_info.h |  18 ++++
 arch/powerpc/kernel/asm-offsets.c      |   6 ++
 arch/powerpc/kernel/entry_32.S         |  55 ++++++++--
 arch/powerpc/kernel/head_32.S          |  57 ++++++----
 arch/powerpc/kernel/head_32.h          | 129 ++++++++++++++++++++---
 arch/powerpc/kernel/head_40x.S         |   2 +
 arch/powerpc/kernel/head_8xx.S         | 186 +++++++++++++++------------------
 arch/powerpc/kernel/head_booke.h       |   2 +
 arch/powerpc/kernel/head_fsl_booke.S   |   1 +
 arch/powerpc/kernel/irq.c              |   1 +
 arch/powerpc/kernel/setup_32.c         |   3 +-
 arch/powerpc/kernel/setup_64.c         |   2 +-
 arch/powerpc/kernel/traps.c            |  15 ++-
 arch/powerpc/kernel/vmlinux.lds.S      |   2 +-
 arch/powerpc/mm/book3s32/hash_low.S    |  46 +++++---
 arch/powerpc/mm/book3s32/mmu.c         |   9 +-
 arch/powerpc/perf/8xx-pmu.c            |  12 ++-
 arch/powerpc/platforms/Kconfig.cputype |   3 +
 20 files changed, 379 insertions(+), 177 deletions(-)

-- 
2.13.3


