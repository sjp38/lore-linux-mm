Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC567C10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 05:59:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E7620693
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 05:59:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E7620693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CAD66B0003; Sun, 14 Apr 2019 01:59:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9790B6B0005; Sun, 14 Apr 2019 01:59:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 868BE6B0006; Sun, 14 Apr 2019 01:59:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 388D76B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 01:59:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e6so7222259edi.20
        for <linux-mm@kvack.org>; Sat, 13 Apr 2019 22:59:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=CtjaAIMATaZT301FHWwKASq1I6bbrjO78ZHKTxU4VEU=;
        b=aMtlmkj7sWeWA5/DIx1Tq5+nb4gYI4qTecsxuvVDDvY15pXIOeH8Ib+QKNpDHd+VYg
         NNJyZ3Vxs3mbAzQTCCb1qVStYVJJl+Q7D/nqd5dV//iU+st2C0zJqZPc13JzdCF6N/to
         A3rlQ4vtr6dAgJG1WUBYCJmXJOk+O0LiZSnbA8dSi5DaDg5ALHJGvxAm61dMYkASr2iG
         ylPx2MSTy+Eb9kLnsVv/UtPAvZjvmpFKe1wYtkZJIuApNF0mdHuJ6HVsH1ydx6rWUgZ1
         rhOzvFhug17pmg6a1J/awxJpz+PY4h2/RRFiSvJwvMOYsmSHIIXxAY+BzYUms7qxS91X
         8+dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXhmNRVNc6IoG1qmSwOhFC8wLkwsSi1GbQb2DfQzhRUgOp8XRkG
	8cblIFJjvPRCKe5nntHnt/cPOOmDU8Wd0KFLmG4Ap275s+EN+kBxAsfvawumt9NJXynUGiGwBI/
	LoZm7rUidQHHFc2SkQboKjK2QzzX/IA1663UivVTC172+l12c5ihifngkQ6YESdGdOw==
X-Received: by 2002:a17:906:c7ce:: with SMTP id dc14mr27701810ejb.143.1555221571577;
        Sat, 13 Apr 2019 22:59:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyq8bhBEFp2PSyyvkcX1sOBtUh6CQkmxF4nyFXcnp4LnLOqQIZNtEOzDWfTs6iugW1EFl+J
X-Received: by 2002:a17:906:c7ce:: with SMTP id dc14mr27701772ejb.143.1555221570518;
        Sat, 13 Apr 2019 22:59:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555221570; cv=none;
        d=google.com; s=arc-20160816;
        b=UblG+uMB6HnYIDaWvvXuptsI3eQ3wdU6Kf+PXKMQvExEEX1p4QuwGxnAmSGz6iNna9
         qoZWDB8u0YFfz1knpKr3EeEU3KmobI9m/sxjeqKo0zvvBRqTv1RKmM8PNAKaWmK8PkTi
         +Bt6V+wdMn9zm3QmievTHqiaZY+GL2U/40OdiPG6ghshCQS1WJCLuLrgDi8RzxAu2gVZ
         isxRB22L2AMZgi2Wza1OHXtA14mpfe44jyUReUbbermC6vrhdnOKHeVHwuvrUTtTBMPV
         HTt8YEa2LF4HdHfNi4n1W71BZayNsU7XmC2BTAvdtd+FOueSM+B6VJOy3K0A3KwfbJgG
         ZFOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=CtjaAIMATaZT301FHWwKASq1I6bbrjO78ZHKTxU4VEU=;
        b=Fy6Hotxqx1EIMt8UZiCoe0ff6EewFUcyT7A4Y3K6wAIo90KfVz+MFYrUEUxX7/q9pR
         5TaV9yxSlFlbcHu+Cx+qfZl5HSsUCBG2WFeUIaYhrlotMRVi3jBM8dsEYjjiwkr7KRK9
         akHXw40jIRxtPR/hyq9GJ0CDdIQIjJAgmcN1jHs9KAwTjxEKhrPvZCKrvFIFHsxRCpK2
         rCYrp64dEVB4j8IvMY0aW4Cvmusf7O4l/WaFwhNCJElug9s6UL3tB0drwK0+xhxY8Gu8
         hLoOahdSKzkgRcSFlv+l1n2ZFycNuivJCx7kWxS0fbIAmWjZB9H2FRwG4wa4/PT7bwfr
         u8Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ge8si2097104ejb.304.2019.04.13.22.59.28
        for <linux-mm@kvack.org>;
        Sat, 13 Apr 2019 22:59:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D872280D;
	Sat, 13 Apr 2019 22:59:27 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 7EC783F557;
	Sat, 13 Apr 2019 22:59:22 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	ira.weiny@intel.com
Subject: [PATCH V2 0/2] arm64/mm: Enable memory hot remove
Date: Sun, 14 Apr 2019 11:29:11 +0530
Message-Id: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series enables memory hot remove on arm64 after fixing a memblock
removal ordering problem in generic __remove_memory(). This is based
on the following arm64 working tree.

git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git for-next/core

Testing:

Tested hot remove on arm64 for all 4K, 16K, 64K page config options with
all possible VA_BITS and PGTABLE_LEVELS combinations. Build tested on non
arm64 platforms.

Changes in V2:

- Added all received review and ack tags
- Split the series from ZONE_DEVICE enablement for better review

- Moved memblock re-order patch to the front as per Robin Murphy
- Updated commit message on memblock re-order patch per Michal Hocko

- Dropped [pmd|pud]_large() definitions
- Used existing [pmd|pud]_sect() instead of earlier [pmd|pud]_large()
- Removed __meminit and __ref tags as per Oscar Salvador
- Dropped unnecessary 'ret' init in arch_add_memory() per Robin Murphy
- Skipped calling into pgtable_page_dtor() for linear mapping page table
  pages and updated all relevant functions

Changes in V1: (https://lkml.org/lkml/2019/4/3/28)

Anshuman Khandual (2):
  mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
  arm64/mm: Enable memory hot remove

 arch/arm64/Kconfig               |   3 +
 arch/arm64/include/asm/pgtable.h |   2 +
 arch/arm64/mm/mmu.c              | 221 ++++++++++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c              |   3 +-
 4 files changed, 225 insertions(+), 4 deletions(-)

-- 
2.7.4

