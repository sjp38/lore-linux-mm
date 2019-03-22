Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A370C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:42:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE6F1218FE
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:42:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE6F1218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CF7A6B0003; Fri, 22 Mar 2019 03:42:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77F0D6B0006; Fri, 22 Mar 2019 03:42:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 621CC6B0007; Fri, 22 Mar 2019 03:42:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07E256B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:42:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o9so574910edh.10
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 00:42:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=uuVoQSuf+9094U8dvrcpi1WtCkgz+3tOu7qt/A6L9wg=;
        b=N6loRiBjooKk56b0CCiPmI3nB1tiZfZQveDMU5TACfmvACnFy4NPKp6Sb1x6NSjam7
         k81mErpAeJ973V3IB1kKV5shXBpERvWLrsXWDHzJj7pkTR0IaPNnUuJ4LMomJ44PiDZU
         bG1rCgCwQDIQeQzjv1iNLqYJseKmM0XyEjU6pePhM5IosdLs8WnxzTH2V5BIk6hrnpBq
         M9T0yzPx0nh6r8ORvB6AEW1jgjhPEverWtk4lePmUoUSMOdRctMzw7AxsKUyB+YT0XhK
         rJHorzvaldSRi3+L+6/wJIGalSn3HLzHWrd0wifUr7BNaxw3siqZt3UEAT1Rd8GhclbT
         GGGQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUdBNpCughxwk3MPo5fnK6ZoPeodnCRsMD4c78Z3CCRU/FL0Edy
	3xG7Lpi7bNx7S2BSvIueBIE04WWYKxEzdEYqda+Ux32vcZGKaIS/kdjErNfx27h0X4ljNDyxmp8
	TzjF/RleVcllQy83QvgTS+NLdk9RfJVupppN5YaZRvJq1Y2tqIvoaO1QFQhtZYmY=
X-Received: by 2002:a50:a4ab:: with SMTP id w40mr1790229edb.281.1553240553484;
        Fri, 22 Mar 2019 00:42:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKn2YnvuPrxv2nU7Yklggogy86DA0s7juiV77sDcZR2Yv2MsFUhp/e4Vd6kw07tLxqw73i
X-Received: by 2002:a50:a4ab:: with SMTP id w40mr1790190edb.281.1553240552604;
        Fri, 22 Mar 2019 00:42:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553240552; cv=none;
        d=google.com; s=arc-20160816;
        b=Wzibj4kh9Mvu1N94ES+8x6NmRA4VoqO0weeVE1cwACFfq/6uRXhn7vs0tMUSbRuswG
         S9ZF6zWIQAbKnwS7thr+vfBaItyh52PSZmQtfD2zLC1YmWXOQrejxqPN9gNiaN7eVUMJ
         IWaUN7JDiDa1iAs6i3zmYdShG37zEewjo2fE5D58W0Q5eoFcFQd/RGkKOre3MU5rQhHi
         ucKvkLvwOMJhDJZkaAqVXJiCTZ1cxvNxCh5GB5cwd2mzYQ2V9l1M1Z4kQ07JkCeWrVwR
         Lk9DtBHBE3+llTpGT2+y8TdY1lU2HMi47Y9eiJloz1tLMTxEOIq97wLIp/PVN4V77hvW
         t5Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=uuVoQSuf+9094U8dvrcpi1WtCkgz+3tOu7qt/A6L9wg=;
        b=BZuBe7C4bqM9ASdK+Rtn8po0KrYQlYftKpmUHO/LQjX0fMqrodC1uDDCcwLKwyucUf
         3D2S48W0Yemsr3hnY9UQEpi+aA/WJ/nPme37+uAQGfxCPj7IB0qmR4PvC9v5rdZ0KpFT
         2zRG5Ihs2iuw6ZU/CY5/JUriYfxuUz2g4X1IsJkwPtXE+Jryhx/Bab1kPszDxSS9+gpM
         vfMjvo0UZC72aStxwPLGLZsOSNKhozoXeuaJa0VxXTwXE2gINfq1pTQRymMW863Mcb/b
         wP1b0LQXgRDA6QCQi/ptMwdBf4lK8PVPBF0x7fwfXjnv5/NiloQ4J0vim8guOoyv4Ozz
         DaYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id e35si1244091eda.186.2019.03.22.00.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 00:42:32 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id C432F1C0006;
	Fri, 22 Mar 2019 07:42:26 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Christoph Hellwig <hch@infradead.org>,
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
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH 0/4] Provide generic top-down mmap layout functions 
Date: Fri, 22 Mar 2019 03:42:21 -0400
Message-Id: <20190322074225.22282-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000318, version=1.2.4
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

Alexandre Ghiti (4):
  arm64, mm: Move generic mmap layout functions to mm
  arm: Use generic mmap top-down layout
  mips: Use generic mmap top-down layout
  riscv: Make mmap allocation top-down by default

 arch/arm/include/asm/processor.h   |  2 +-
 arch/arm/mm/mmap.c                 | 52 ----------------
 arch/arm64/include/asm/processor.h |  2 +-
 arch/arm64/mm/mmap.c               | 72 ----------------------
 arch/mips/include/asm/processor.h  |  4 +-
 arch/mips/mm/mmap.c                | 57 -----------------
 arch/riscv/Kconfig                 | 12 ++++
 arch/riscv/include/asm/processor.h |  1 +
 fs/binfmt_elf.c                    | 20 ------
 include/linux/mm.h                 |  2 +
 kernel/sysctl.c                    |  6 +-
 mm/util.c                          | 99 +++++++++++++++++++++++++++++-
 12 files changed, 121 insertions(+), 208 deletions(-)

-- 
2.20.1

