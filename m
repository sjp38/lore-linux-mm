Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76454C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:39:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34D7D20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:39:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34D7D20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEF7E6B0003; Wed, 19 Jun 2019 01:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A79328E0002; Wed, 19 Jun 2019 01:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9414F8E0001; Wed, 19 Jun 2019 01:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45A4F6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:39:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so24467464edd.22
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:39:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=U8wwWkMc4xREbydMVGhGOpMQaRQYb5wF9yJW/vXkBZ4=;
        b=ZvoecCVlEhvcxdSpJ79NO5SbUuQ/PWbNQkzKRO8E9aqsi4g42vmOXNpXtZmKzgG5N5
         Eon20Z5x2kuOcLkp29XvPgJ4cYsO/jNbGm8sw04wPPM6/V8ZgRRTvH3aZoLKhZY9B5Sv
         D0kOwLctgVWaVIs2UG+1SA3GGg+hlsImzXpHhhrEAenE58sKLxvuIX06W30Td4qQhAOa
         secXHREa6dVtjrSryY/LNYQ8LDyyaXPJNNQsBA3qiYUdTeJW0WehRtCA/24SOsaFn6AA
         DuwctloS1dePTgHNZ27UCBkyyKU7cE+AsZegfrQEPq0YmMfGKYxpNj7sZN9gyUn0PtfR
         jgHg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW2D5yDrzErFgvNbDt9efZ9v4OUPMO3zqJmz2Fhj+P6WOVdN74Q
	x+JhpELKCj/HpO/CZ4nRLUuN+QN6j90NAn70o7lnAcyfVPQoRROLVjElqxLgASO6bxjyzOyqxm2
	Hk2w8JpS9L3kJ3p+8PC7SSeZQVNpE6+RnrDFA0qaPS9ANkX9J8LvQq+V5V7C0Psw=
X-Received: by 2002:a17:906:6051:: with SMTP id p17mr34021622ejj.142.1560922761838;
        Tue, 18 Jun 2019 22:39:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGzvMniMD2A1rGHEyCTQcy4tDGtZW+swt7eJLSIkULSUJAUTo+OeHVfU6bf/z2c00InZq5
X-Received: by 2002:a17:906:6051:: with SMTP id p17mr34021593ejj.142.1560922761068;
        Tue, 18 Jun 2019 22:39:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560922761; cv=none;
        d=google.com; s=arc-20160816;
        b=BNbElfYdgmZqkd4oZyIaj1iCuNQz97Fk4UV3j+Ds0hDj/+LmDxYEtMkBUcRW4TGFLr
         +QnxGAr3m1W/Abx1fvnjoG0y0Q+mVIHi5FD7Ed4e6e6bHQ6zEJboB7pkcR9KornwGiI6
         yxTPT+VDjQGdJGgNGUVr0yyvW187KnCeUFNT2cvmJ8wr4ynXTc55qFFFWHMp5988Ojno
         q6ipYQGOmzT6XJM/Ssk5b65QvWLObKde6q1rJttNEYLZJ+bKTrx8en6zagkobWQ+9Adn
         fx8wr14RnHduubTogp9rtm7icUa3+eTe0vODhVQG2+p6qbquZ3KFy5M/7+cFfVrDgp7H
         qYhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=U8wwWkMc4xREbydMVGhGOpMQaRQYb5wF9yJW/vXkBZ4=;
        b=a4NbJM5Ek6SlLGa2M8uNaVPJHhw5KbDPcZdM05IXLmjALCVfl4GG5BT/lv+ffcAkmr
         X2IKTXPSWG8cPqTS+yjVuvDqaqQ9labAgIopJDDYNqI8xIpm36MnKB2GBQ2IZKM/RbtP
         YdlLjGXfmMHsEWVY2HLNI2eno6dOxtjbuHf7nyi5gfnY0ovqz6QcPHCZ9WtT/6RdZ4np
         FTuBpuxvZgQbNF09ojOy7nTY738x2muaC9m+4h9fNNsibchl+cYWnYLi8SD1dW984pLP
         hpu4h5PfHHh5c7R5mTT+5D31aKnlJak63tR4DVSPKP4MxmMBoWnFB971+xBEG3lpQ35m
         4eOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay10.mail.gandi.net (relay10.mail.gandi.net. [217.70.178.230])
        by mx.google.com with ESMTPS id x10si12809987edd.307.2019.06.18.22.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:39:20 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.230;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay10.mail.gandi.net (Postfix) with ESMTPSA id DE71124000B;
	Wed, 19 Jun 2019 05:39:07 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH RESEND 0/8] Fix mmap base in bottom-up mmap
Date: Wed, 19 Jun 2019 01:38:58 -0400
Message-Id: <20190619053906.5900-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(Sorry for the previous interrupted series) 

This series fixes the fallback of the top-down mmap: in case of
failure, a bottom-up scheme can be tried as a last resort between
the top-down mmap base and the stack, hoping for a large unused stack
limit.

Lots of architectures and even mm code start this fallback
at TASK_UNMAPPED_BASE, which is useless since the top-down scheme
already failed on the whole address space: instead, simply use
mmap_base.

Along the way, it allows to get rid of of mmap_legacy_base and
mmap_compat_legacy_base from mm_struct.

Note that arm and mips already implement this behaviour.

Alexandre Ghiti (8):
  s390: Start fallback of top-down mmap at mm->mmap_base
  sh: Start fallback of top-down mmap at mm->mmap_base
  sparc: Start fallback of top-down mmap at mm->mmap_base
  x86, hugetlbpage: Start fallback of top-down mmap at mm->mmap_base
  mm: Start fallback top-down mmap at mm->mmap_base
  parisc: Use mmap_base, not mmap_legacy_base, as low_limit for
    bottom-up mmap
  x86: Use mmap_*base, not mmap_*legacy_base, as low_limit for bottom-up
    mmap
  mm: Remove mmap_legacy_base and mmap_compat_legacy_code fields from
    mm_struct

 arch/parisc/kernel/sys_parisc.c  |  8 +++-----
 arch/s390/mm/mmap.c              |  2 +-
 arch/sh/mm/mmap.c                |  2 +-
 arch/sparc/kernel/sys_sparc_64.c |  2 +-
 arch/sparc/mm/hugetlbpage.c      |  2 +-
 arch/x86/include/asm/elf.h       |  2 +-
 arch/x86/kernel/sys_x86_64.c     |  4 ++--
 arch/x86/mm/hugetlbpage.c        |  7 ++++---
 arch/x86/mm/mmap.c               | 20 +++++++++-----------
 include/linux/mm_types.h         |  2 --
 mm/debug.c                       |  4 ++--
 mm/mmap.c                        |  2 +-
 12 files changed, 26 insertions(+), 31 deletions(-)

-- 
2.20.1

