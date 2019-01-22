Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A08FC282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53B582054F
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:28:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="XieHotxU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53B582054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5E598E0003; Tue, 22 Jan 2019 09:28:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0AFC8E0001; Tue, 22 Jan 2019 09:28:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFAA58E0003; Tue, 22 Jan 2019 09:28:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6226B8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:28:50 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id x3so12266603wru.22
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 06:28:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=y1h7NEIo+CtMklvBEgXPQBAxMK12PjZZsMrZCcoeYxU=;
        b=jZG0sN5t6Cx8F4x+NRHH32NKbclx9snYLLyARQa1BJS7s7y2/QRwvWBQF/eVAhgCyJ
         gcuahKPD0N/+YEj0yKFzISLkqJVlYO0mM6jmGK+5jZzuSU2APbi2V+TBYPuO1/TTRlOq
         ew7w31LCN3JAOYdBikbSUEDNwBbxKzUkaKM/1gg1ycSzdBzvH7kHSyhrZCLosSf4DA2u
         NaWTJ1b2hlfP16RiLWirouL/nphE6ot4u/HhAaTlSyY5vuea5M1szoMStkukjFgrdK7P
         uSg4QOxUub+lTw6XheRwscmj9lSD7xmKcYUoLEShjiPfhFD09gsWoS8OPG5jpa5/nf5Q
         cZsg==
X-Gm-Message-State: AJcUukeLI5OPynPQmr1dy5z/TBwTtNJLG7O37Z+Ic0WHz6Qvg//vLojx
	Ywkwps/3qIiyi5zSZtDNYmBlHVdFGURZ05d1oJMElcPF94FU2V9LtG1Iz9wo4M2VF2Khfbo4L23
	TtouN3RB4fjiBUJ1avT1tMtsq7IiSfp82NloTjI1mqly7gSXhx61Zi+ZaazJTQoIWbA==
X-Received: by 2002:adf:dbcb:: with SMTP id e11mr34585936wrj.58.1548167329719;
        Tue, 22 Jan 2019 06:28:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN65MMpbdHrzsJB9Bo8JxkoPSsog0hpJQsaBvUyg5Uj3eDAIr2xyMB2FiP2yj765tajAFxEy
X-Received: by 2002:adf:dbcb:: with SMTP id e11mr34585871wrj.58.1548167328552;
        Tue, 22 Jan 2019 06:28:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548167328; cv=none;
        d=google.com; s=arc-20160816;
        b=j2qEJIoA4tGx+4m9iY4S4BIBJtcGBNJOba97ERBm8jFvmNsjf7sRZPQ9qnhqBQExYy
         eYlzRi49Ikii3NpR4WqxA7AcOA2AjqhkdM0uknI2iFnq44LHP+VN6mvXQmwJs2msKQtn
         xuU2QJ4Z7VnQ4QB7II9/SMXJd0alomsbRR0+hQd7XCSw+VcXX99xllfFunETsAnccXqD
         pxd9zQ9q1TIv8NWPMV3I2GZcCRBW4KfhmaHWMewBKQZj4MbTOUNlXvwgIFs6dZcpGS8r
         UDK7Uh821Rcj4Y9jtc2gfG82RwtDJpRmtBgHxG9O80iJSLsgC4iG5h3aMKRJ/OlJ6c+g
         D2Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=y1h7NEIo+CtMklvBEgXPQBAxMK12PjZZsMrZCcoeYxU=;
        b=pYspEvxy6F+e64WZQQgJ4GKcKd30BrJrcflCUYCteR19wTNpeCo75pXny8uGO916cV
         p9GknaOLm8NJCxQI54QzBDXm/FVpQKSlIPOxM9iUo0edTNov5yglbwK8JULVUDgnogQ/
         scmprFElsMjsBG8uLrVm4j8EjY4fiyGx2fxcFL3cHtcsTyJkboqkyEe5NIb1yiZ9PBMD
         PENTcCLv5naoUl/aGWZ0oW8WbSw4xRPGdlusrNog5ckxkPjdg5zQBMFrzOlkq9kaYxQs
         6EIsPmJ5QfFTgSKzQz9n7API0abqmzKnoSpyFXGyy97UlOCV7qBhezIjmBgvYTEgwuY/
         iz1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=XieHotxU;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id u84si35352873wmg.158.2019.01.22.06.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 06:28:48 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=XieHotxU;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43kW4Z3L7pz9txqy;
	Tue, 22 Jan 2019 15:28:46 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=XieHotxU; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id yAQHnjqpKivF; Tue, 22 Jan 2019 15:28:46 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43kW4Z1Rkfz9txqk;
	Tue, 22 Jan 2019 15:28:46 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1548167326; bh=y1h7NEIo+CtMklvBEgXPQBAxMK12PjZZsMrZCcoeYxU=;
	h=From:Subject:To:Cc:Date:From;
	b=XieHotxU2KZYSB97SDpVLpAMGYX785fb23S+hnGQ8Xp73oWgP+jL2CvjZ+YPLh7Rw
	 qzZHpVtBWN/LROgH1zTl/2ZknH3skNEt4WJc0uZJUN3CHWqhUqDpM5/F8iCFoP0HkB
	 S0THWNYWYUC5oq/SAHUHC4jm20f6uhS+Yc+Ip7Fg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 940768B7E9;
	Tue, 22 Jan 2019 15:28:47 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Lx66DWK1ASNv; Tue, 22 Jan 2019 15:28:47 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5E1C48B7CE;
	Tue, 22 Jan 2019 15:28:47 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 77C2E717D8; Tue, 22 Jan 2019 14:28:40 +0000 (UTC)
Message-Id: <cover.1548166824.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v4 0/3] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 22 Jan 2019 14:28:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190122142840.-hatCeG7ZTJpKvkXdBRu-_GatgEGZsJc0u_611etD6c@z>

This serie adds KASAN support to powerpc/32

Tested on nohash/32 (8xx) and book3s/32 (mpc832x ie 603)

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

 arch/powerpc/Kconfig                         |  1 +
 arch/powerpc/include/asm/book3s/32/pgtable.h |  2 +
 arch/powerpc/include/asm/kasan.h             | 24 ++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  2 +
 arch/powerpc/include/asm/ppc_asm.h           |  5 ++
 arch/powerpc/include/asm/setup.h             |  5 ++
 arch/powerpc/include/asm/string.h            | 14 +++++
 arch/powerpc/kernel/Makefile                 | 11 +++-
 arch/powerpc/kernel/cputable.c               | 13 ++++-
 arch/powerpc/kernel/early_32.c               | 36 ++++++++++++
 arch/powerpc/kernel/prom_init_check.sh       | 10 +++-
 arch/powerpc/kernel/setup-common.c           |  2 +
 arch/powerpc/kernel/setup_32.c               | 31 +---------
 arch/powerpc/lib/Makefile                    |  8 +++
 arch/powerpc/lib/copy_32.S                   |  9 ++-
 arch/powerpc/mm/Makefile                     |  3 +
 arch/powerpc/mm/dump_linuxpagetables.c       |  8 +++
 arch/powerpc/mm/kasan_init.c                 | 86 ++++++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |  4 ++
 19 files changed, 236 insertions(+), 38 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan_init.c

-- 
2.13.3

