Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E9D2C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:57:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC1AE20818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:57:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC1AE20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E2B96B000C; Fri, 12 Apr 2019 14:57:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 568A66B000D; Fri, 12 Apr 2019 14:57:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40B806B0010; Fri, 12 Apr 2019 14:57:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E13936B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:57:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o8so4876784edh.12
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:57:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=ujJ0DYmqniuNwFOvCY0zbfv81F8EOhf9L5eg0pYQnw4=;
        b=tkqEcb3qLt+p8ehCLdVW6BCYYQa0X5BzUBSqLr+1rbhRRlCCV5NICUkbMhctnzOn9b
         zK7z45qaHWLrgnXEy81spe0GN35EuL8NzS3wl98SLY1jXIRX/t5HyTk8KjBul05ewLoq
         o836tWQ+p5b5zHxZvdsBH3b7b1a+3v6i7Y7v3XredItQkpujBDEK/ZZbP2zYH0W3MclI
         WcVh/A8zP9Y19ugY3IJp2pELLYIVbXWSnUcHC19pssmjZZrkPC8TyVldSnydvnZe9QEv
         Tku/FQm2oR871l8STD8YgPx9Rk3dq7iFHpHh/TT1Ze0aHqkGJPDMlUoEcOEXaebaMnkh
         KSxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXfY/yATNQH/i2y9KaUUpgfVL/diQ6rA1VJwkToOuktBWPQyLfq
	xjBptbvpYHDiRoGAigqNlobCMbgELB5LwDVS3Lsq6PY077aIrJ/YLYdJOzUnNiePFk3Yujl0Ztu
	iAb15PMqtLAqB6v+Mm5nbHYozasLPsywPjEtrNq/bHTHmi3pVSG86XnjpqjVlrcpmBw==
X-Received: by 2002:a50:a510:: with SMTP id y16mr9093750edb.167.1555095443415;
        Fri, 12 Apr 2019 11:57:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGQTaZj4pPCrfxrTLIxRT1O7rDdbAX7xQbkbrpu7VKxRe8dAISPFIWDbbUFIiLn1rS4T4U
X-Received: by 2002:a50:a510:: with SMTP id y16mr9093700edb.167.1555095442383;
        Fri, 12 Apr 2019 11:57:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095442; cv=none;
        d=google.com; s=arc-20160816;
        b=RpZDZasd3C4Hzm2xjZCCvYhUMgjNFNIsyKsYualKp57/5nTagjgsC+l9ZKdyTYiikt
         dzeZuI1Qv8sxTblSu92C+LeAiJupb0tEDYa6AsjWMNR5or21hi94Zpl4Kpnj0ZgndpBw
         IIBwNH8TA+SGoCB+TfQjipLlkO8k4/vPKQ+vR3S7yoj+pTz2sWX8gMarQGa5q9VI/dT3
         BrweKxhvix8pBIZIqzr45cRPL3Fqkl79iQnPR02+MlKSul4/6eSnES/mGqPtSPCE+/q9
         zUJh5l8Zo/kGdZFQQT1ZuYNCqJ8SUY0stfRDpEhCDiqNdBKmj/wKTLxqn5/WuSgVoZIY
         Lkzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=ujJ0DYmqniuNwFOvCY0zbfv81F8EOhf9L5eg0pYQnw4=;
        b=R7VGGxjAU7FxnMk/HN4u8NzWydcCAV95M270W/VySTOB9isi38mnG5lFdZ9iiUP4rD
         Ip21ihBhMmy3rOlQC3hqrfBYi4+hUx05k3vOYh/5opVhO1hnLIleKfIZGLbUw/SlxVIa
         9ae9LSqFe37tMngagTT2eZiXqv3iwmOdXWfVtiTwoIL1IckaxETrHSsrCooJszycLyqn
         SxCrEpHFQY2+rYy5EaAm5c3zP7fgujqqHVcVnbgN2z8lSv1IJoCV0AEYbQ07mSDj77zE
         jRHAp1cq58HcIrx3+D5gRMwn2MGS248XTz1NNDDL+mvE107JOhBDC6ou0RYVIoRq0BE5
         Pdvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m13si2870501edb.67.2019.04.12.11.57.22
        for <linux-mm@kvack.org>;
        Fri, 12 Apr 2019 11:57:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4A06A374;
	Fri, 12 Apr 2019 11:57:21 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 9D0473F718;
	Fri, 12 Apr 2019 11:57:19 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: dan.j.williams@intel.com,
	ira.weiny@intel.com,
	jglisse@redhat.com,
	ohall@gmail.com,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/3] Device-memory-related cleanups
Date: Fri, 12 Apr 2019 19:55:59 +0100
Message-Id: <cover.1555093412.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

As promised, these are my preparatory cleanup patches that have so far
fallen out of pmem DAX work for arm64. Patch #1 has already been out for
a ride in Anshuman's hot-remove series, so I've collected the acks
already given.

Since we have various things in flight at the moment touching arm64
pagetable code, I'm wary of conflicts and cross-tree dependencies for
our actual ARCH_HAS_PTE_DEVMAP implementation. Thus it would be nice if
these could be picked up for 5.2 via mm or nvdimm as appropriate, such
that we can then handle the devmap patch itself via arm64 next cycle.

Robin.


Robin Murphy (3):
  mm/memremap: Rename and consolidate SECTION_SIZE
  mm: clean up is_device_*_page() definitions
  mm: introduce ARCH_HAS_PTE_DEVMAP

 arch/powerpc/Kconfig                         |  2 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h |  1 -
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/pgtable.h               |  4 +-
 arch/x86/include/asm/pgtable_types.h         |  1 -
 include/linux/mm.h                           | 47 +++++++-------------
 include/linux/mmzone.h                       |  1 +
 include/linux/pfn_t.h                        |  4 +-
 kernel/memremap.c                            | 10 ++---
 mm/Kconfig                                   |  5 +--
 mm/gup.c                                     |  2 +-
 mm/hmm.c                                     |  2 -
 12 files changed, 29 insertions(+), 52 deletions(-)

-- 
2.21.0.dirty

