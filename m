Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02EC0C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 05:59:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6200218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 05:59:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6200218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 410696B0003; Wed, 24 Jul 2019 01:59:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 399D86B0005; Wed, 24 Jul 2019 01:59:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 262C26B0006; Wed, 24 Jul 2019 01:59:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8A7C6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:59:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so29516253edu.11
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 22:59:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=phQRGIZX8xdyAO/X5+InkRxHhCZVhZ1aazOhRZzbJc4=;
        b=QzqKFl7MU9KKJusa2N+uz6fqAey1ZSEiJEQMgntk9QGRixz4GZqO40b9FL6SIwsHqw
         ffcTfvwWLPGGoJLJ9XBx4Ytih6ptKcMNOrFGcUNKeCUDtVrjyj4tePBoh9OJYbDBhmnh
         Xnztgsn1CdInK6hmbgVaMjqac+JF16Nq1GwPBRnEm99pJVJhqAQtrgV0PsqADbku9t6Y
         7bQYZ2y2SX1FQFj54Q0j8VJL04W4ge2eIXO8yjgCK0hYuIRmLtjxCUcFPQp9DB2kDPhx
         bdpeXsSys1n1QR7RCjYdkgFmka9Ji0zWEzN8qEYBR9cOV8L7p6vRUSzs2EncJZQs4Kt8
         kKaQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW1IFC3fzU3Tp1DDSOl4Ru/bE2HzNKJ4FkBz/cC1Q2xzm1AXIpH
	1QLW1SX3rQoy6xBQKXcDNHnXfGTCj0SuEdy5Q2E0nfb+aAljvleKvTiDouJcp3BVlyIf3R3/IU/
	gqeKdD4vXnNsKZZvRhg8BWKcHlTocRfzGC+DWa7GlkaB9vkG8H9RPHKp2sX8WFN0=
X-Received: by 2002:a50:f4dd:: with SMTP id v29mr69256304edm.246.1563947942330;
        Tue, 23 Jul 2019 22:59:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzD+fvAc96fx30nmSa4udmyBfZdqPrDPLEGhs+fhYNZjFj+nHdt0dA3AAE5pVLZDGAKaWt4
X-Received: by 2002:a50:f4dd:: with SMTP id v29mr69256273edm.246.1563947941424;
        Tue, 23 Jul 2019 22:59:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563947941; cv=none;
        d=google.com; s=arc-20160816;
        b=ZbQX+u3Zp1WuIjy1z/eH+wnZaRFXxRfO7dz+IPUYHzJ1xaQwPkpKgdXrEX2MfRTe4G
         jEq5ydr6WEA8EoIcOjTan/86a/7veOhuyqkfSOs5LOA99I8tuhVxSpUvTgm1nz7/rJmH
         v8jStc9ZzNUCV/K8cYf5tkI8WayzNQhZnMsjksErkN+G72wo14L2CfYZhxbSI+w5Nlf6
         MH97CmSam3LihGFNFqk0bcItXiYWqDQ+BC9HUWq/BE8zNtchtS4+i1WLM05FmS8+p2Gt
         7GARjxRIhlUF1rBk9K61EpVm0C/7K2Hny0LAkaIB50dwWnyFdILnUZDO9A35U65K+Pe2
         +TbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=phQRGIZX8xdyAO/X5+InkRxHhCZVhZ1aazOhRZzbJc4=;
        b=DEBw0d4j6kfq/Dynomapvv9tx/lazoEM8iO6usPTMOTtfKnd8yz8V4m9Pc1XsWcgg7
         1RNHy1NRdU/43ts1SEBHPNbefrYKyFgFnraMLx6DqfUGq40EBXAPW9rwb+6GTAA92st6
         DU10xPIR+Tw5nkrEcoG2/FQ7m1aJ+pyl1bpQsI8d6IjRtSWsprwNXtKsZblY/46JiQja
         jSkdKO2RgVS5Hb+MkbrVIx8XVkp6bPRHryvfAcKC58SZyHnTLK5G1bWKISBlSewGG16n
         T0cY1sYaoSuTFqlOipbO87v6QocEa23ZI/+bx0+PTtBSAAgZKh6a6UHNij4g0H0PG5mh
         /fJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id c37si8201951edb.308.2019.07.23.22.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 22:59:01 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 8CC8220004;
	Wed, 24 Jul 2019 05:58:54 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH REBASE v4 00/14] Provide generic top-down mmap layout functions
Date: Wed, 24 Jul 2019 01:58:36 -0400
Message-Id: <20190724055850.6232-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

This is simply a rebase on top of next-20190719, where I added various
Acked/Reviewed-by from Kees and Catalin and a note on commit 08/14 suggested
by Kees regarding the removal of STACK_RND_MASK that is safe doing.

I would have appreciated a feedback from a mips maintainer but failed to get
it: can you consider this series for inclusion anyway ? Mips parts have been
reviewed-by Kees.

Thanks,



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
 arch/riscv/Kconfig                 |  11 +++
 fs/binfmt_elf.c                    |  20 ------
 include/linux/mm.h                 |   2 +
 kernel/sysctl.c                    |   6 +-
 mm/util.c                          | 107 ++++++++++++++++++++++++++++-
 17 files changed, 137 insertions(+), 256 deletions(-)

-- 
2.20.1

