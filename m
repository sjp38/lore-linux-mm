Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 877EBC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 454F120818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="s5YUCq9h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 454F120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1B868E0005; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B74FD8E0012; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B5798E0005; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54E848E000F
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:06 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id i18so2181443ite.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject;
        bh=PSFgfldcbVtDUFVAt7qodl/dNT5nnx/gaEZnzy4Yky4=;
        b=hNTmUZ7Xd2BnCN3QRc2PMxD9ybjddGizNd0T5qfYb4vf954Dr7s4I5yERObgqo1vPe
         XEhOolAyYugyOywBXCJ+37KMAoGmvKoe4qu2xqQ0324Jmhk27HAqdbR9J8d22SIh3MS+
         3+W2qYMIUD4wqoE0EZ6w8XVMAt4Er1tVMYXwpyrNh0tKFbEXV2n1AEc+3qY+jcKysGwn
         MbqMp2k8ZTxB0TA/vaaeCTBynnRYDlL56tXjl5NGUwAm0wy/zwHFzBKr9pZ7qVJoxGtE
         IU/hs9OS/WfFn0Ejs9hOXp7NYNUg8L2kVZTZVW/JoQtS0HQ/wNd8htrbu8PrynhYCW11
         46oA==
X-Gm-Message-State: AHQUAuaOrDunSklZiChVFRnqSkQabZ6CBLD64XQi/jxjciSWm3ULwtEt
	5NoJ5m/qLxGFojeO6pB8tkTj3RRf3PNtsSZj27YbYeocEBoaDv1rQgfHr5Uz7WTvEMpCDiOTMqT
	spIKgSh6b4uKCiKcnVOpLWNXzKzBnW5PJY9xpozolT2DtbQb75r4lV0CfZAA3OH8SZA==
X-Received: by 2002:a6b:7418:: with SMTP id s24mr16055670iog.61.1550572386143;
        Tue, 19 Feb 2019 02:33:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaBUH2Aisx4nCqsfYywUV76z65vVGGreZoltIOBqub5Aw2DvtLRUanHkbkkqDg96jARbe63
X-Received: by 2002:a6b:7418:: with SMTP id s24mr16055643iog.61.1550572385480;
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572385; cv=none;
        d=google.com; s=arc-20160816;
        b=cTsi2kOeftvP2+YMOiPWMT1Ky/UeB6ryDhm0dHm+9g2fAUYZ5twBAJf8T7FHzftwV1
         agrqRr1tmFbk0fandGscw+2sRFSvJp2MobzLEjZ1C2u1TxZN8m41MUrOZ+UYbO41WEzo
         NCizf3L/dN5OTebLtf70IlsjKYuhbfxWgvEe75zDGskRM7NHKRCYJ0Khaj90yszF9Gga
         mzQNDObLieTxnb6Yx7u8qNDQ9g+PsX15tEFADM4LfeJ/i6ozrP8NJImMJiKwJRRUFJDx
         8yYRxO64sxtZXhSAByYpELRG8E9HIttsUkWxXwBHBA55z6GcXZCxDFJ8LFQL9vX0C7w3
         C7qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:cc:to:from:date:user-agent:message-id:dkim-signature;
        bh=PSFgfldcbVtDUFVAt7qodl/dNT5nnx/gaEZnzy4Yky4=;
        b=qVMGxRK6j5jpxiMITAYcLGF8CsNB7BC7gk2Wea9NWf6gfdHgzT5y3uC3K9nVeWuh/u
         SyI9jmzVZ1Co9nVb1JDyMErY1pDP6UX2lkk2LxeHJun/RRCle93SWBkCNJIlO6Rfg8Ms
         xU6vHbQHggsGWtYI9aoB4h8TJrv4UINKPcWn1wx9Jz7GknE9h1rQbPq0Fcp6HswdV/AC
         iWZBhAEgyRx92HnN5jqmme+99NexUnvdojX2O8cv8z+6UmSQgE82493dnCc7WTg8MGMu
         /Pwris7UOxbTz4MlSX70XVroP7a7/HpOt5Z+1+uD9lc29oZ7MIO7tyNtPIlS26YblN7B
         3JNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=s5YUCq9h;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a25si9336464ios.129.2019.02.19.02.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=s5YUCq9h;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Subject:Cc:To:From:Date:Message-Id:
	Sender:Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PSFgfldcbVtDUFVAt7qodl/dNT5nnx/gaEZnzy4Yky4=; b=s5YUCq9hkR4wmhTU2b7gKBDMb
	IGmJBg7OauupRy627IBcPmAaDfKTKQAGh/P7Rzh4+ej2KZxFwAqd7f5Dua686lrWZ6s567m+gCIuG
	gdwSGWDnNY9eqXcVVDrr/0MmUm+FelMO9fDerySKeH8GBtgXXwLkCJmshHt2DjiOb76I+B+x10K5E
	ggnlHgbkJw+tRr4cpK6i+glaxZwLzaFBKR8fj/4gBQsKjusolE0FRQmfBxJiCWFPA8iFHi+NWyQTm
	mFz1nbhZyLZ/G6wE4h06HHQ8p/+A31RgjRfSBqdz1PmfQN16wg7TsqH7XtMyeLzG9fmDrRQhVMfQI
	ZNkYsfGxA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hm-0000dY-0O; Tue, 19 Feb 2019 10:32:50 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 4430A285202C3; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103148.192029670@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:48 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: will.deacon@arm.com,
 aneesh.kumar@linux.vnet.ibm.com,
 akpm@linux-foundation.org,
 npiggin@gmail.com
Cc: linux-arch@vger.kernel.org,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 peterz@infradead.org,
 linux@armlinux.org.uk,
 heiko.carstens@de.ibm.com,
 riel@surriel.com
Subject: [PATCH v6 00/18] generic mmu_gather patches
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Sorry I haven't posted these in a while, I sorta forgot about them for a little.

Not much changed since last time; one change to the ARM patch as suggested by
Will and a fresh Changelog for patch 12 as requested by Vineet. And some
trivial rebasing of the s390 bits.

They've sat in my queue.git for a while and 0-day hasn't reported anything
funny with them.

  git://git.kernel.org/pub/scm/linux/kernel/git/peterz/queue.git mm/tlb

I'm thinking this is about ready to go.

---
 arch/Kconfig                      |   8 +-
 arch/alpha/Kconfig                |   1 +
 arch/alpha/include/asm/tlb.h      |   6 -
 arch/arc/include/asm/tlb.h        |  32 -----
 arch/arm/include/asm/tlb.h        | 255 ++-------------------------------
 arch/arm64/Kconfig                |   1 -
 arch/arm64/include/asm/tlb.h      |   1 +
 arch/c6x/Kconfig                  |   1 +
 arch/c6x/include/asm/tlb.h        |   2 -
 arch/h8300/include/asm/tlb.h      |   2 -
 arch/hexagon/include/asm/tlb.h    |  12 --
 arch/ia64/include/asm/tlb.h       | 257 +---------------------------------
 arch/ia64/include/asm/tlbflush.h  |  25 ++++
 arch/ia64/mm/tlb.c                |  23 ++-
 arch/m68k/Kconfig                 |   1 +
 arch/m68k/include/asm/tlb.h       |  14 --
 arch/microblaze/Kconfig           |   1 +
 arch/microblaze/include/asm/tlb.h |   9 --
 arch/mips/include/asm/tlb.h       |  17 ---
 arch/nds32/include/asm/tlb.h      |  16 ---
 arch/nios2/Kconfig                |   1 +
 arch/nios2/include/asm/tlb.h      |  14 +-
 arch/openrisc/Kconfig             |   1 +
 arch/openrisc/include/asm/tlb.h   |   8 +-
 arch/parisc/include/asm/tlb.h     |  18 ---
 arch/powerpc/Kconfig              |   2 +
 arch/powerpc/include/asm/tlb.h    |  18 +--
 arch/riscv/include/asm/tlb.h      |   1 +
 arch/s390/Kconfig                 |   2 +
 arch/s390/include/asm/tlb.h       | 130 ++++++-----------
 arch/s390/mm/pgalloc.c            |  63 +--------
 arch/sh/include/asm/pgalloc.h     |   9 ++
 arch/sh/include/asm/tlb.h         | 132 +----------------
 arch/sparc/Kconfig                |   1 +
 arch/sparc/include/asm/tlb_32.h   |  18 ---
 arch/um/include/asm/tlb.h         | 158 +--------------------
 arch/unicore32/Kconfig            |   1 +
 arch/unicore32/include/asm/tlb.h  |   7 +-
 arch/x86/Kconfig                  |   1 -
 arch/x86/include/asm/tlb.h        |   1 +
 arch/xtensa/include/asm/tlb.h     |  26 ----
 include/asm-generic/tlb.h         | 288 ++++++++++++++++++++++++++++++++++----
 mm/huge_memory.c                  |   4 +-
 mm/hugetlb.c                      |   2 +-
 mm/madvise.c                      |   2 +-
 mm/memory.c                       |   6 +-
 mm/mmu_gather.c                   | 129 +++++++++--------
 47 files changed, 477 insertions(+), 1250 deletions(-)

