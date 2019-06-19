Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BE62C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E71E4208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:09:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E71E4208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FDCB6B0003; Wed, 19 Jun 2019 01:09:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AE9B8E0002; Wed, 19 Jun 2019 01:09:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 477218E0001; Wed, 19 Jun 2019 01:09:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFFE86B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:09:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so12587451ede.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:09:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=rlfuBatknSoexbXQq8Uk9ryMN1twJ+Icien1yK5z69o=;
        b=hA98Y1j7d5ympgaJBju7F5o6GAp3UEvY1DEO6NOfAlcxcZblb6RcyjtSSpPhbBg3J6
         MvvhMEWfRYgCH/Zj1SLqzNKJuOi8jWz96wG2bj0DEdiyXbWZ2odMrkE8NNKVTXuJjg/y
         2BJcXmXiubmq2h8qK5zjg+KfffAa1zq2SFEwYT7u4TUWygNg31PxW6NVS6wvtfCpueYR
         GQcBFaiXBUj7vKfpOBU5bzPXGwSmSCWvIqCOEZ3baW6Tu1+jik54QWFjA3eVbUEAvbyp
         gjSsmY3wb9DMDWvwF+2vRIqbJCrwyCZlKIykatawBA7hCOgQSSPCwmmKSpDu8caRQ+LI
         mxNw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUrEjv49srJh5BCwqO+/lNO9ThHPb5+kiuC8GckTh6mUIYbsJFv
	5SrflN3+ydM17w7tTIGjUFU4zJBRBbhJVp4D2wC+uaPHcRcgJ13/tlZBu/Y2BYFQvQRWxZRFhKY
	SYC8rM/VmnVvCOmibqSCGpNmePyqghKZmms0nPT5F41kK3IH0H6jd7J/vHTBMIG4=
X-Received: by 2002:a17:906:76c9:: with SMTP id q9mr21965744ejn.236.1560920953467;
        Tue, 18 Jun 2019 22:09:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwT2s2i3Gxjfh/2kkIPjkf1IOGcITAG0Z4PfN2B+k8ZtrH/DbKw9mO/syKl0LI8uy3erBJk
X-Received: by 2002:a17:906:76c9:: with SMTP id q9mr21965670ejn.236.1560920951904;
        Tue, 18 Jun 2019 22:09:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560920951; cv=none;
        d=google.com; s=arc-20160816;
        b=ZzdAkzK2QrFzU363N4kyJmu8kvUwWJPRLb3IqlPJkMbzDfoZz4k+vV4pEA9jVzt/3m
         cXu0EUqf/q5AzYqD+rzEwgyTKiRPERMCS7ZLe88AA/e6N2ZfNInYG6WFNwv1UHnjQmG/
         7wGOHCkb4KZ5RkOoDFdfGhbt0uMWsw3FFixDczFWJlFaTQuln1SG1b51PAi6ALUJ99e2
         Cbtfvj4VsunhKs+y9qFqQ5N8bFVpaziJ3qaVzozV7jIhQsfXjfHXyndJexJmUtMLuJdn
         3UtQV7Rkdz4WN+5bltiV+uliEwuftehM0u+PX6k3nauSHdepG14jRuSd5hEnhH9H9xH0
         DweQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=rlfuBatknSoexbXQq8Uk9ryMN1twJ+Icien1yK5z69o=;
        b=s5EqS1ABFz+etQ3JMlPT9+o01x/U6Y9VAL0g9/B72UTIKq1DC8cOgerDqIgNfSziXo
         WZjhOC8ImxILv4j+G3uuyX74RrYckeGqQZ3teDMat2e3JcrjW2tZIbNfHUiKF26QZuAr
         RmzUwF/MpElxlUKaPG7wwrt0Ai79wzQCo99p5sXZ3WPzy6QeaJIfUUxqKneWiuXgtnnp
         yUyx4ZVYEYuv7oGCTMlelGZ/Gr7FvDrpJ206sj/xYSnfJplckXfqUUVQeWwAGAR+Y9kh
         LO2/oibFpgaNqbrwUQSyqt0+qrazmbNQFb2TzVd3udBYpMs3ukMqzb6EhGCZTMre2uj3
         e+bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id n12si10187012ejr.105.2019.06.18.22.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:09:11 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id C3AB120006;
	Wed, 19 Jun 2019 05:08:57 +0000 (UTC)
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
Subject: [PATCH 0/8] Fix mmap base in bottom-up mmap
Date: Wed, 19 Jun 2019 01:08:36 -0400
Message-Id: <20190619050844.5294-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

