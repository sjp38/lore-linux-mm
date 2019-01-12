Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E937FC43387
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 11:16:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A274820881
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 11:16:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A274820881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3544F8E0003; Sat, 12 Jan 2019 06:16:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 301178E0002; Sat, 12 Jan 2019 06:16:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CAA28E0003; Sat, 12 Jan 2019 06:16:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id B66108E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 06:16:36 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b186so1222472wmc.8
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 03:16:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :from:subject:to:cc:date;
        bh=acIcupVwoKkCDZUd0Xb1zTEODtBl7tIh84HoXVuBN3E=;
        b=gfXmX3V92hQBYQDl3GF178MnCAdzmI2qv8JNFe0S0G3tJkMuufScADEifLz7BB7cCA
         wsSL7dcgRwB7Wg+Qn398N4i6MJSM024EzePD+SGoZRFGyko+Np6OCFPDx8FVcLp+nSBl
         hxk102PYABhwmEVux4gb/STVoeNA7XwqHFtykfb6DhOnMsEH+bjMkMAJ51nQ2JOaVefK
         OsNR/ZW1tz698IZ8VZ6fhpKoqExLK/3F34gGI+gtDybpYh2SR5qe/hHD2nDBBQOzLbwH
         zvvaHj3v9y9FSCqA/icpKCw1hsoxlWqLoWaCN0B35KQWgjX5T0Htu8SuaaejuK6q9mMX
         jfNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
X-Gm-Message-State: AJcUukcHRruEDoJD4wowV2rVziFRVlTKbtXFl8h3fBFpOcC2RQWtVj/M
	fK4uvxfaUVEqc2l6q35xGgcC+wgAFATCx0VYrjXHZfymgzvsdMD3IXKSUGSlhek+bO07dl8fzOF
	6lQcm0A9lxP/mMFzN6BiqUSUj+EEo5+GyxrKcJpw0ViM/oAQ59qCd/ilv7Sgn6CEYpQ==
X-Received: by 2002:adf:dec4:: with SMTP id i4mr16474924wrn.307.1547291796098;
        Sat, 12 Jan 2019 03:16:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7PBotB4AaGJsByugD5ipFy17MeY3eW1hORSfMDAEaJH0qTyu8fPX+uvKoRdWKkh/iB53ok
X-Received: by 2002:adf:dec4:: with SMTP id i4mr16474867wrn.307.1547291795099;
        Sat, 12 Jan 2019 03:16:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547291795; cv=none;
        d=google.com; s=arc-20160816;
        b=AEm5n/xOp926k/7n6x+OU+EbmVs2XbEYObpokT2Q6bRGkE5aL9edjGEyTriY5hXIj0
         OvvSxWlDb/oqLO/8XrUUVD8JsIDxmO5sXjl/EwaTZ3HrZ+ueZnm8JD708RaWP37S4GNc
         GbIIGkWQRGVJzkxi2heGwHvqYtaL1jKr8arJfFlaTYFL/jckKBKW27txBr9nwHDLwnb4
         bvzmcVWG5rU55OXWNk01DI/UjXC2R9nrYN+XmmmpjRpaT6GYKZ5Dx6S21X2TbWanAMS/
         2vUykN6xdtFmCXCoFzFWB60NMaKWo68UNAnqQR3pdnrHeUkz6Bh9fgo/zufFBvYj3IN4
         bkRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id;
        bh=acIcupVwoKkCDZUd0Xb1zTEODtBl7tIh84HoXVuBN3E=;
        b=N499eQ/f6Sb8TUKjspgdOtgq8wXqPXgd1E6liJeYptd4N4g/AKki8fzHDdfo1QejHW
         0i4m/DySeN2Qc7j77EeLMjcWwYwZBVPlrsqnYZvjsKV1+EEHy2qzJr0QNMh8sxYASDe0
         VxWt0ipUlOAlTx52Rdp9z+JFtmSUbcr4oMW/2r7kz9SFic1iPfYWCVZslEki1gAfkBeY
         q5ipOddKZ+54XaPZw1tQ223pw3Vt+ZjepYUzqB02ffPxeYqKDUohb7oMKLeQAausqtIN
         tnmMweLbNWURZCwPTb3xVxK+Tj7461AUFwxJe+Z8Iz3xpYzUKzoUtN56SUf+Oe+8qGPS
         MC7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id a16si15290152wmd.137.2019.01.12.03.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 03:16:35 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43cHHM3bBbz9vBK9;
	Sat, 12 Jan 2019 12:16:31 +0100 (CET)
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id MB9UhAN4a18M; Sat, 12 Jan 2019 12:16:31 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43cHHM2yXyz9vBJm;
	Sat, 12 Jan 2019 12:16:31 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 56A418B77F;
	Sat, 12 Jan 2019 12:16:34 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id cM2U0KOIla5y; Sat, 12 Jan 2019 12:16:34 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2321F8B74C;
	Sat, 12 Jan 2019 12:16:34 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id D9D40717D8; Sat, 12 Jan 2019 11:16:33 +0000 (UTC)
Message-Id: <cover.1547289808.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 0/3] KASAN for powerpc/32
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Sat, 12 Jan 2019 11:16:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190112111633.i_vGqitAEA8exwG2I7JQ9CpDxKn9ano2hqTfS_8fNJE@z>

This serie adds KASAN support to powerpc/32

Tested on nohash/32 (8xx) and book3s/32 (mpc832x ie 603)

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
can't use the same pagetable for several PGD entries.

Christophe Leroy (3):
  powerpc/mm: prepare kernel for KAsan on PPC32
  powerpc/32: Move early_init() in a separate file
  powerpc/32: Add KASAN support

 arch/powerpc/Kconfig                         |  1 +
 arch/powerpc/include/asm/book3s/32/pgtable.h |  2 +
 arch/powerpc/include/asm/kasan.h             | 24 ++++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  2 +
 arch/powerpc/include/asm/ppc_asm.h           |  5 ++
 arch/powerpc/include/asm/setup.h             |  5 ++
 arch/powerpc/include/asm/string.h            | 14 ++++++
 arch/powerpc/kernel/Makefile                 |  6 ++-
 arch/powerpc/kernel/cputable.c               |  4 +-
 arch/powerpc/kernel/early_32.c               | 36 ++++++++++++++
 arch/powerpc/kernel/prom_init_check.sh       |  1 +
 arch/powerpc/kernel/setup-common.c           |  2 +
 arch/powerpc/kernel/setup_32.c               | 31 ++----------
 arch/powerpc/lib/Makefile                    |  3 ++
 arch/powerpc/lib/copy_32.S                   |  9 ++--
 arch/powerpc/mm/Makefile                     |  3 ++
 arch/powerpc/mm/dump_linuxpagetables.c       |  8 ++++
 arch/powerpc/mm/kasan_init.c                 | 72 ++++++++++++++++++++++++++++
 arch/powerpc/mm/mem.c                        |  4 ++
 19 files changed, 198 insertions(+), 34 deletions(-)
 create mode 100644 arch/powerpc/include/asm/kasan.h
 create mode 100644 arch/powerpc/kernel/early_32.c
 create mode 100644 arch/powerpc/mm/kasan_init.c

-- 
2.13.3

