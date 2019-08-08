Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1085C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B13152186A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:18:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B13152186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3729C6B0007; Thu,  8 Aug 2019 02:18:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3223B6B0008; Thu,  8 Aug 2019 02:18:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212EE6B000A; Thu,  8 Aug 2019 02:18:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C59AB6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:18:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k37so840191eda.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:18:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=wb2cleiecjleZvJFMX7JjAm5W0pLl5fYOnfZHBlHBg0=;
        b=IUixfH5h1/kuXSHg9WgYA+cLxXwvNXv4CPdcIvRaZK/M2sfiT+9PXGp78F/2xl3Ndg
         HDQrpzMD96WTqdECX2IdggGBZJ8Wqhl4zyeQojn8m2PLiNeg5Sgv7Oam/DlHm4l9N1e7
         8cP89MsG9x1vllSfEtqMuDf6l4sTiXT0lJj0RrkJjGieAQ4PKUdcsF5B+l49lsppYo4h
         /Ogvey/PWbI5RX5zOP9WfYp/1OJt67bk0ENa0b8RECkIwO7c8w12ND0DNmtCutTkfdY6
         ECv6p061d3N7ghZi2XKwlh9OLZ9RoqrAZOI2WC1Fb2TYTH1/GP6KP7iXlUgj6HfonAaS
         zMSw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXVc7JS0UIt04QR3V8UXSFjwZbJgnjtr5TurjXYPO80XMna8EcT
	40Qd6sJPtKtRB5jlAnuqDW3/t/up7eaoA5LhaHYp6kZfTbHsqrX3dRtMeZliayhLRyxCRf9Yq9x
	C0S7vCsjEEzoH9NMt70vbS8bH4XKrytQhyI8c/RDuLgfCA6FMPkhKb9EdaCVSGq8=
X-Received: by 2002:a17:906:4d19:: with SMTP id r25mr11677101eju.125.1565245089321;
        Wed, 07 Aug 2019 23:18:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw16nX8B/90BVkAv3Ac+G7vW+noGl04vybHJ8hN7AOj2s3T547vSwhsDfMPkVfauHXONYP/
X-Received: by 2002:a17:906:4d19:: with SMTP id r25mr11677046eju.125.1565245088175;
        Wed, 07 Aug 2019 23:18:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245088; cv=none;
        d=google.com; s=arc-20160816;
        b=GfoL0jMGC8KOF/R6ak7MUQO18JojmRtDXfuoahp84UroRlk7yUvZ6gwxKuB6kDg78D
         TRl2W6FrWs2cU+G3Xs2sjKfoBK1e+VqaY5qZUy2GY5mvqlQtgu5RgbympnoSEUpLjBfI
         Xt49fToVplHOclsv66Uad6vLPMvkhQCHwkm+B0vMGjB8vuhf8pkkkZWeAg244P7vgtX/
         JBQ81VPOmbIzAiUPbKvSL4b201rPd0AcdORFz05+Rh7zy6JHpjI0TD4c/04K0fXdYd14
         sU92FjEDeUqvHKS+EiYDDXM9wmKVz8NyLYRcFWUZ+KVXZar6CQJFV2Iy5AB4bnZabiyH
         tYxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=wb2cleiecjleZvJFMX7JjAm5W0pLl5fYOnfZHBlHBg0=;
        b=Bgj+SsBBzkfW3FmQNRdEkFRIxJIth5JK6c6aipu0p/EjlJuKM3Qqk0CNRbpkH1i0/B
         /Dxc4AUJ4VNPyMHO645aE7Sa3Q/KO2mQPFjRbulleZtQGRyrD2D6N74J5pYsK08KOEJm
         NKbEg8u9BRWUaPKmCEuQYBwt9LeJ5rKP3YLa0qPhVU7jH6RbsnGySysXLXTGxQzB9zh8
         fAkM8tKlrMBLdXEq0SHWqlaW6PPRrbMsBLP6hVfNkaRh8ZnYy0xqRHZ662H0tDRttqoE
         sedZ74Ffyr9Cx4bKfj6TnHLaUufFicSjL0ViMu38qBQp0gWoLqvaew1qI5/gqLCajauk
         4Fog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id y54si35136446edb.416.2019.08.07.23.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:18:08 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id F38AC100003;
	Thu,  8 Aug 2019 06:18:00 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 00/14] Provide generic top-down mmap layout functions
Date: Thu,  8 Aug 2019 02:17:42 -0400
Message-Id: <20190808061756.19712-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series introduces generic functions to make top-down mmap layout
easily accessible to architectures, in particular riscv which was
the initial goal of this series.
The generic implementation was taken from arm64 and used successively
by arm, mips and finally riscv.

Note that in addition the series fixes 2 issues:
- stack randomization was taken into account even if not necessary.
- [1] fixed an issue with mmap base which did not take into account
  randomization but did not report it to arm and mips, so by moving
  arm64 into a generic library, this problem is now fixed for both
  architectures.

This work is an effort to factorize architecture functions to avoid
code duplication and oversights as in [1].

[1]: https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Changes in v6:
  - Do not handle sv48 as it will be correctly implemented later: assume
    64BIT <=> sv39.
  - Add acked-by from Paul

Changes in v5:
  - Fix [PATCH 11/14]
  - Rebase on top of v5.3rc2 and commit
    "riscv: kbuild: add virtual memory system selection"
  - [PATCH 14/14] now takes into account the various virtual memory systems

Changes in v4:
  - Make ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT select ARCH_HAS_ELF_RANDOMIZE
    by default as suggested by Kees,
  - ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT depends on MMU and defines the
    functions needed by ARCH_HAS_ELF_RANDOMIZE => architectures that use
    the generic mmap topdown functions cannot have ARCH_HAS_ELF_RANDOMIZE
    selected without MMU, but I think it's ok since randomization without
    MMU does not add much security anyway.
  - There is no common API to determine if a process is 32b, so I came up with
    !IS_ENABLED(CONFIG_64BIT) || is_compat_task() in [PATCH v4 12/14].
  - Mention in the change log that x86 already takes care of not offseting mmap
    base address if the task does not want randomization.
  - Re-introduce a comment that should not have been removed.
  - Add Reviewed/Acked-By from Paul, Christoph and Kees, thank you for that.
  - I tried to minimize the changes from the commits in v3 in order to make
    easier the review of the v4, the commits changed or added are:
    - [PATCH v4 5/14]
    - [PATCH v4 8/14]
    - [PATCH v4 11/14]
    - [PATCH v4 12/14]
    - [PATCH v4 13/14]

Changes in v3:
  - Split into small patches to ease review as suggested by Christoph
    Hellwig and Kees Cook
  - Move help text of new config as a comment, as suggested by Christoph
  - Make new config depend on MMU, as suggested by Christoph

Changes in v2 as suggested by Christoph Hellwig:
  - Preparatory patch that moves randomize_stack_top
  - Fix duplicate config in riscv
  - Align #if defined on next line => this gives rise to a checkpatch
    warning. I found this pattern all around the tree, in the same proportion
    as the previous pattern which was less pretty:
    git grep -C 1 -n -P "^#if defined.+\|\|.*\\\\$" 

Alexandre Ghiti (14):
  mm, fs: Move randomize_stack_top from fs to mm
  arm64: Make use of is_compat_task instead of hardcoding this test
  arm64: Consider stack randomization for mmap base only when necessary
  arm64, mm: Move generic mmap layout functions to mm
  arm64, mm: Make randomization selected by generic topdown mmap layout
  arm: Properly account for stack randomization and stack guard gap
  arm: Use STACK_TOP when computing mmap base address
  arm: Use generic mmap top-down layout and brk randomization
  mips: Properly account for stack randomization and stack guard gap
  mips: Use STACK_TOP when computing mmap base address
  mips: Adjust brk randomization offset to fit generic version
  mips: Replace arch specific way to determine 32bit task with generic
    version
  mips: Use generic mmap top-down layout and brk randomization
  riscv: Make mmap allocation top-down by default

 arch/Kconfig                       |  11 +++
 arch/arm/Kconfig                   |   2 +-
 arch/arm/include/asm/processor.h   |   2 -
 arch/arm/kernel/process.c          |   5 --
 arch/arm/mm/mmap.c                 |  52 --------------
 arch/arm64/Kconfig                 |   2 +-
 arch/arm64/include/asm/processor.h |   2 -
 arch/arm64/kernel/process.c        |   8 ---
 arch/arm64/mm/mmap.c               |  72 -------------------
 arch/mips/Kconfig                  |   2 +-
 arch/mips/include/asm/processor.h  |   5 --
 arch/mips/mm/mmap.c                |  84 ----------------------
 arch/riscv/Kconfig                 |  12 ++++
 fs/binfmt_elf.c                    |  20 ------
 include/linux/mm.h                 |   2 +
 kernel/sysctl.c                    |   6 +-
 mm/util.c                          | 107 ++++++++++++++++++++++++++++-
 17 files changed, 138 insertions(+), 256 deletions(-)

-- 
2.20.1

