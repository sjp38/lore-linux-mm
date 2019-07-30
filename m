Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92519C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B7602064A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:51:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B7602064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D91718E0003; Tue, 30 Jul 2019 01:51:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D431D8E0002; Tue, 30 Jul 2019 01:51:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0A008E0003; Tue, 30 Jul 2019 01:51:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 704E68E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:51:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20so39650736edr.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:51:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=EV9pj4iT3kjVJXbfaqQRno+8EcReZOYDq0jfLGxZ2zo=;
        b=eJwsvuEOXUwiT241Xm3eluVD4LYW369qW2vASttMnEQ05egCdsXmx8O7eCZXuuAu2T
         5K1/4rLIEqgsF3TtkNHeI4+vmRLw92t381KXPc+JsfdUpsevcO0LCRN+Q3gERKIgB9hI
         oOpx1GXeOGwhxH6/K+3k6+Dic/k1z3G8IKMlDCwpl/ht2GGfzhdi+/CGwnedzwlLIOhf
         GiguRx5BH8b3MtbUoR2fkwBOtIUQC4BrWvpnGBxm9WxR6WgW5ZNr+fuV/p3DFhRenTeo
         S5M949azrYRDCdk+QmdX5THavp2HqGiuVBr7GzeK58ZzZMLBnk1uq9qWCCQBDMxb/XNi
         IQyQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUr2pwgl6847oS0uU4PIOX6lOaf52dFlYsK3DhrCPOiCF98XBBk
	Z0XFjRWRGXpnNk81a9DT44C2e0YgMCsOTSuJG6xsVTqf2zfqAIF37Q5elqLwfA8p2OgdjG1SAn/
	d1FUcSoded6yyM5sJ0UQXCDLoOoVlRAANrCvP+IH0+uWOySr21mimfsLHThANUZs=
X-Received: by 2002:a50:f74d:: with SMTP id j13mr52419528edn.254.1564465892991;
        Mon, 29 Jul 2019 22:51:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOhLbC8K4ch5wAza6dPTzBAuuDLLo5zIOEfwv/7mE+O6xiAU+vDBfN9Ww0+thBBhwk/YzG
X-Received: by 2002:a50:f74d:: with SMTP id j13mr52419460edn.254.1564465891833;
        Mon, 29 Jul 2019 22:51:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465891; cv=none;
        d=google.com; s=arc-20160816;
        b=c8RpCFZ44gCC1lKnyF4U3DnlLHl/gBkzUPVyambnHcVY+sH/5oXd4oipqVFBebZcMT
         uTiQw3ZXV3GvX8wwx0lmkm1u4OCJQrdL78Zzj+AbqeltWF7pW7/FTh0x5DvW2lBVGp6J
         P8UsqB5UGzG/R0cW4YzrOZiNuZyMfoW5zmOrMTrK/rjsDqFfJWb1OiXnc9YoMiHEuwr3
         ZYNwl+iDtG3TGgp2mVajNL1YKXx3gKSduT2Lqwy527oKjGyGKFo/Hc1CsyC4HiXUEIOo
         W5PsM73F6y1HR/LKv1nBx5K422JiAqqpAyvibC/uVxRqmmkr1joEDGvjtCni2U+9ANd/
         W7DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=EV9pj4iT3kjVJXbfaqQRno+8EcReZOYDq0jfLGxZ2zo=;
        b=Op1eVaSwCOubKbLmFG3wWUh02WThBtgJSuHie19gpSmELxZQWDTY0CxZ2a3WIjvBhL
         Xb71HnHcu3dRJG8Qg83v6pYIF074AhdgVLMqvmC0Gw6i60T6qcFbPZGn8HyqGR+oD4vl
         lYRe5LhfIwP/C4GcQ1vtPRYnynoOXf/IJ76EXUIEzSz9/O5czz1EzjSV65Dzi8Dn4IOS
         8GqBxefwmb0ra7dFz+0y/R+rSMbJxPsLseTPxnBb1hJKM4vAdAFffUhh4kE0r753PKMt
         Acd6O4eSH7NATxD+vJwu1mcOlJTwZWVU9fhs+jOrTV4iZ6h1LlspGGG9wTaI6+VqKO+i
         hELg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id d7si15925914eja.286.2019.07.29.22.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 22:51:31 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.201;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay8-d.mail.gandi.net (Postfix) with ESMTPSA id 18BD71BF20B;
	Tue, 30 Jul 2019 05:51:25 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
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
Subject: [PATCH v5 00/14] Provide generic top-down mmap layout functions
Date: Tue, 30 Jul 2019 01:50:59 -0400
Message-Id: <20190730055113.23635-1-alex@ghiti.fr>
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
 arch/riscv/Kconfig                 |  13 ++++
 fs/binfmt_elf.c                    |  20 ------
 include/linux/mm.h                 |   2 +
 kernel/sysctl.c                    |   6 +-
 mm/util.c                          | 107 ++++++++++++++++++++++++++++-
 17 files changed, 139 insertions(+), 256 deletions(-)

-- 
2.20.1

