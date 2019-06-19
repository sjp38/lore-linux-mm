Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC743C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:42:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAE3F20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:42:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAE3F20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 547556B0003; Wed, 19 Jun 2019 01:42:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F8AB8E0002; Wed, 19 Jun 2019 01:42:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 399788E0001; Wed, 19 Jun 2019 01:42:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E16FD6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:42:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so24513176edp.11
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:42:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=rlfuBatknSoexbXQq8Uk9ryMN1twJ+Icien1yK5z69o=;
        b=THptxTnRs81ftm2ZDbuqQAuNGlxoOA6rjQAt3U1iL8hc2p2n/xT4qpxJKplRrWIKiT
         5Tv/z5iHdsClonTJyogeagMX0oj1MDFSVViDv/7V6P5luv4TcqA0DXMlqVOJGGRQbNQ4
         rLzkHR4qVDOviVmPzwsVy1ZRvu3UB9PzQ/OBB3F+Pt/q/CDL25V7vdn4gL3R2Zk0B9nk
         pNcYOEduJbsCDg93svyJfd9n0RbjH56wmqadqlJPvKtw0I/HW94jm/y1D7nQ/xlQxKYY
         YgRVfNA9LtL73uNs/KhhUO5N0R3C+RHT8mRO8L1e3jbSmo8XyM+2lRE8vq2A8UYez/O5
         fqeg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.194 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWRdhk7rf8kg6+jdqxqEPh2QLokTFUOnoWtjgxUS2bOQOcDOWHZ
	Ne7OKcIJRgUK49Kk4me2HMZVZp1qwFwf84kC+xvZs/d8aaybdDPV7NYLND3fWZV5M6Xg2N6iNN7
	47fOQHbU3k0tsI3T8ZNEUPdUGwQAaJhHmVqNa/hK5ZP+hDhf9scLrhL9Aw8BMcQQ=
X-Received: by 2002:a50:8bcc:: with SMTP id n12mr107189114edn.6.1560922960502;
        Tue, 18 Jun 2019 22:42:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyADK158EjsbJZssmm+TPoeI1WYcr+WdliAECHdA/5ODyuDH4y9Rp0RjOW6JrcLgMINiKPK
X-Received: by 2002:a50:8bcc:: with SMTP id n12mr107189079edn.6.1560922959892;
        Tue, 18 Jun 2019 22:42:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560922959; cv=none;
        d=google.com; s=arc-20160816;
        b=nf9zcnE5JTUQekThMkudYtYgIs2S8S5WjZcfLTru4lwAmHvwUK7q1iS3ZQQ0qdShEf
         wiuNpl5AohyNJmZOIRPMflE2TVDg9nvDTIl+YWXDbOCiNokd7rdMsE5ViTxMBFCoXiVL
         4h9Kbzj5B16BhiOAh9wtpS9jOpGxejfJf8pZ/SWx/d3PGD54K+YUd8Os+lH/Wq2y/gyb
         1q0sW/Pb28+E5VMe9MHjfMlB9yCWDJtaZfOwTgC6indgdEUFDXruNKoZ/rvS6ActlHxU
         uuzBesnxOnEsJeyq0V1Tnfzx/kvAD5/HgPNHPrW5zC7Q5FEiCxbuGMdjXKKgogqBiFJM
         +gvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=rlfuBatknSoexbXQq8Uk9ryMN1twJ+Icien1yK5z69o=;
        b=cHW+ZhpszpqdDrq/Hde8OHP/ebyXy8cAMKuFZsd4F+oNXOE2f7pNo8wC95AoY5cHHk
         bSWwdKjK5onGx7tj1SmhybKXOv3nsUnXc74ZJOgul1Urc4mD+uLhXbWYVUC/XA4syDgt
         vArehkDVzrT2v3nGXYUyejvKA6qy6EmqhLTxI1pZPBWmEE8BBD78woRlxOzcl0Ar1Vsq
         9myaTSJVdRAtaOLuhF0qPUBAZxD8EZL+hljPwv/FIDXeARNOSlbH9HB5pew/oY4H6h0D
         LEwodKs4J/XCfSmtI22bkiknWNNO8aWtCOqhvSLH7UUurEEsG0HIAnErnhacaoTm1eIf
         8KTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.194 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net. [217.70.183.194])
        by mx.google.com with ESMTPS id r15si10327968eju.331.2019.06.18.22.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:42:39 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.194 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.194;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.194 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id B0F1240011;
	Wed, 19 Jun 2019 05:42:27 +0000 (UTC)
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
Date: Wed, 19 Jun 2019 01:42:16 -0400
Message-Id: <20190619054224.5983-1-alex@ghiti.fr>
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

