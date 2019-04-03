Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D640BC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C8AA206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C8AA206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 382166B0285; Wed,  3 Apr 2019 00:30:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3327C6B0286; Wed,  3 Apr 2019 00:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 221CF6B0287; Wed,  3 Apr 2019 00:30:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C73156B0285
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:30:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p88so6799457edd.17
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:30:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ghOAGygeV4mRf0AYIdMFxGnPsIW6ZxCON5D6gDJqSBA=;
        b=Na4Hu6cA7g1CMiReDLQrG2eXQBKe4y8p+oDOrLxwd/ayxYyTweMtOlZQyk2yS455+O
         R357EZLYkMZpGFkYzhbXNduwhGLOE7yqCTzspqD/cqobPE5ba+z4711b2ijhMh8LIi5T
         bpPb5ZJeY8PpIZb1zLd7rqc2eu3O6AdEvq28+0aRWFrTL4D/fW4tgl4AJn/G49tHWAeX
         t7ARSJ1utMAmMrE0xjZXPaPq+vc+0e0rhnzJFEMn7h9EDbFbHLQ0z7Jx6HvjNtS0vUCm
         k3d8Tmm5+uUEA9IrvPZ2JUk+Juc9jaZQ1sTGQNmDcBhGyqJD2jgFdtbG5SNBaXgi9gbz
         RfLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVYgbFQ5CqJWWWl0BnkWyHYjMDXRTYiKDiNti1VOgN2sO3yTgbq
	jEbvbDVWgFrAINKdG3PVef372ZCe2zrWie3Iervn8P25VTRo8NvNSJKpJKuzuey1qZ98JdEzsaI
	xhEeooFdP4msGj6fhTo5VKZIHVw3u7cKXhAZW6r/obJIC0Ps9ooy46/uPgKYTAhBbfQ==
X-Received: by 2002:a17:906:824a:: with SMTP id f10mr35051539ejx.105.1554265814312;
        Tue, 02 Apr 2019 21:30:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRt5rA7hhJx0RfJx1kb+lGcmzP05r4ZnXxIpWMqvnROhmi+UrlRwnM+xvnFMRR5n4hCQlF
X-Received: by 2002:a17:906:824a:: with SMTP id f10mr35051509ejx.105.1554265813383;
        Tue, 02 Apr 2019 21:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265813; cv=none;
        d=google.com; s=arc-20160816;
        b=hVbz0KffWPV4OB967sBM3HlCXZkLWeHirr+9aZop5ikGYnQkO0IYwILN7WmVg3YeK+
         KDHP2iM6vsMM8Z7f+u61nQZctroYXOGSuMvtWXP79rCtUJ/HblnJtXbtzHwWHf294JUM
         WoJ46YZiSCdVL2bpR1Cdh0iuogx+Pwr00E2oWSDuNzmzal5+zQL7mmapmCWIepgwHGOx
         VWxcf54kI/+EgyjgS6tX39oPd3iCn4TbOhK+9bLAgL1wkvLcrvtPjtNPNJ3/2s39wdOj
         r+nYaHkCDlyYlfdTZhbXqEElGPu9Si0y04uqcObrUphtZMmt+d+N2Ct5nXNIEtkX8SSd
         8a8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ghOAGygeV4mRf0AYIdMFxGnPsIW6ZxCON5D6gDJqSBA=;
        b=AZV0Px8FOL0w3R3LUsLfnor36eEZTzJ98L8dLCjxMgsMOtRD5fiEUPpZiEPtvasqom
         5oHwz5PzMNXxiYUlKjFgSzH/8QfyCtFp8xGLFT9j2cBEs0eBtCxIOQBIdNBtoa9h7Sal
         3aBfAwF47KtS8pml6yGxWTpOVkRnMqWuHTmR8eMyrXuYLnEQLWpn7BXvjV3FjGQJkFTi
         HSSF8zeZ0rSPMP8/iMfIHgLlK60jRiHXjDcKklsziIWJxkuotlAWExhLLKHQGARd5zo6
         zoVJecv9Q2pTx/U5/dKIFwqyB5hp5S/37cuHKLM09po3TgIHmjxysEIQZcme8d+2ZU+e
         EZWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h17si699993ejj.366.2019.04.02.21.30.13
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 21:30:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2E40380D;
	Tue,  2 Apr 2019 21:30:12 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.97])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id BE65E3F721;
	Tue,  2 Apr 2019 21:30:06 -0700 (PDT)
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
	logang@deltatee.com,
	pasha.tatashin@oracle.com,
	david@redhat.com,
	cai@lca.pw
Subject: [PATCH 0/6] arm64/mm: Enable memory hot remove and ZONE_DEVICE
Date: Wed,  3 Apr 2019 10:00:00 +0530
Message-Id: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series enables memory hot remove on arm64, fixes a memblock removal
ordering problem in generic __remove_memory(), enables sysfs memory probe
interface on arm64. It also enables ZONE_DEVICE with struct vmem_altmap
support.

Testing:

Tested hot remove on arm64 for all 4K, 16K, 64K page config options with
all possible VA_BITS and PGTABLE_LEVELS combinations. Tested ZONE_DEVICE
with ARM64_4K_PAGES through a dummy driver.

Build tested on non arm64 platforms. I will appreciate if folks can test
arch_remove_memory() re-ordering in __remove_memory() on other platforms.

Dependency:

V5 series in the thread (https://lkml.org/lkml/2019/2/14/1096) will make
kernel linear mapping loose pgtable_page_ctor() init. When this happens
the proposed functions free_pte|pmd|pud_table() in [PATCH 2/6] will have
to stop calling pgtable_page_dtor().

Anshuman Khandual (5):
  arm64/mm: Enable sysfs based memory hot add interface
  arm64/mm: Enable memory hot remove
  arm64/mm: Enable struct page allocation from device memory
  mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
  arm64/mm: Enable ZONE_DEVICE

Robin Murphy (1):
  mm/memremap: Rename and consolidate SECTION_SIZE

 arch/arm64/Kconfig               |  13 +++
 arch/arm64/include/asm/pgtable.h |  14 +++
 arch/arm64/mm/mmu.c              | 242 ++++++++++++++++++++++++++++++++++++++-
 include/linux/mmzone.h           |   1 +
 kernel/memremap.c                |  10 +-
 mm/hmm.c                         |   2 -
 mm/memory_hotplug.c              |   3 +-
 7 files changed, 271 insertions(+), 14 deletions(-)

-- 
2.7.4

