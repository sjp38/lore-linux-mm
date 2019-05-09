Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5A07C04AAF
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:46:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACA582173C
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:46:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACA582173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 478716B0007; Thu,  9 May 2019 00:46:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 402836B0008; Thu,  9 May 2019 00:46:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CAF96B000A; Thu,  9 May 2019 00:46:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D10026B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 00:46:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r20so548866edp.17
        for <linux-mm@kvack.org>; Wed, 08 May 2019 21:46:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=erpFmp3VLDsAOMv7VvMVAaqBi78LNY8tDAh1d6RKhCY=;
        b=ny+Mp35E93bP1ze2IrO5ltO/3m/Ope4WDfwJyQFojVLSr66YH5rhB5ALZ9Lfde/RoC
         qUcNDRvwcvj0WuHth0BNgaZUaytG1L0hfFnEIwADxICFmgpfj96ZAt8bsUiLj+V47Htv
         F0Q6jAJMSaZUCbbtyxUko92ceSe3SBC+DfwprGvzZSPfZTzgoWGtcX+JFpdpTlyCR7qV
         /pOjfWIQow6Am7B1Kia4CyQzse49LVDZWQSeHrNZ1ey62fKYG/3B8oH+sBkQCOh4IQVK
         lq0UlXnDYqlS+7lvTnPOiPg4Y3sKJz7j23MmWP5H87V02CeQ1mv7dySl1li9SMSJMJ27
         UDpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX5fWRtIBi8wkiGRagfmu39cPPGxcDoIezcMZ3x4wD8Tp8KjnYS
	qZ+O8hqel7An3dF1kIDwgnUB07N4dXD3AaDLI1v8RNZE9FNJo2MZGN+cUlry4ghFiRfNDKYBqcf
	+v6LSPbkEh06HSTQBRFvik08bc0rf5qoZQXnQAMpuhbXw7JYAn3Yq0eaBCLIozeZGfA==
X-Received: by 2002:a17:906:1545:: with SMTP id c5mr1473312ejd.135.1557377217290;
        Wed, 08 May 2019 21:46:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5Lnpa7WiwiLPjwVoNcov1ETM12lRxkhwXggGtP+1cE9WnHPjlJK+EUTvFxS7VflBgoTw1
X-Received: by 2002:a17:906:1545:: with SMTP id c5mr1473272ejd.135.1557377216261;
        Wed, 08 May 2019 21:46:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557377216; cv=none;
        d=google.com; s=arc-20160816;
        b=H4bq3whlbC4/R049UPljOi/Gv5vbgQlm4lzITrTRNWD39gPUGQXuyOOmuS5OfYBGlR
         wA+4GDSusP4bBOo4VVpAFZ+xf7CexmDT2DaXIJ0TKYKEvy4dOxG8eQgF6+Ckv4DrWkHo
         fFmOR6uXyUL7r05YAFIWHX4jhmAoZTAMcsAuRuO+L4LFOxYfiTpDd4TuCbp06mECKZsc
         Lzxvt2lXXTu9VvPA5OMV2Sx3MmlL8mm7CmviGfJYuTf7bg1FIPIp2LJJZYm5vdJ/NR/p
         3kjHPJHOty2/qzZecfyiT/ZmRXpRKGN5pu8D5JG7BEWTN7cuvWvM1r1MBDNYQZI3ekPt
         It2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=erpFmp3VLDsAOMv7VvMVAaqBi78LNY8tDAh1d6RKhCY=;
        b=zzoUcSXlkX8P5xFAIzrgwuYsdZkQesSY3KB4ss6/4BGZsD7FuZuP7LXqAgh7Byx6RH
         pC6L8rmj2muQRPgr228sspTXksJjq7gcgMxXq6U/iIINcSHuK1oqOey4hzUmq4+NolLF
         nsq6cVD3JZ5LCRiUDP3vTupnVRUZxtTuXVFDDifyphN9UlrCTeDgqve61CzTh9BH+wX/
         KBppFR34YNr79+icfEVHuvHNXpyTNL88L13Y2XZ1E9PjtLDEZZ0bB4nDHqzJefe+R2Pd
         Mn2BWuPmC/PAUEj+BnvqlhuaJB2ayhgJYxJId6qmsxXuasBDbVYLdrqEOGNgaPg5j2Jd
         q6RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j8si488185ejd.47.2019.05.08.21.46.55
        for <linux-mm@kvack.org>;
        Wed, 08 May 2019 21:46:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DF70C374;
	Wed,  8 May 2019 21:46:54 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.46])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id BB8733F575;
	Wed,  8 May 2019 21:46:47 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Deacon <will.deacon@arm.com>,
	Toshi Kani <toshi.kani@hpe.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Laura Abbott <labbott@redhat.com>
Subject: [PATCH V3 0/2] mm/ioremap: Check virtual address alignment
Date: Thu,  9 May 2019 10:16:15 +0530
Message-Id: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series makes sure that ioremap_page_range()'s input virtual address
alignment is checked along with physical address before creating huge page
kernel mappings to avoid problems related to random freeing of PMD or PTE
pgtable pages potentially with existing valid entries. It also cleans up
arm64 pgtable page address offset in [pud|pmd]_free_[pmd|pte]_page().

Changes in V3:

- Added virtual address alignment check in ioremap_page_range()
- Dropped VM_WARN_ONCE() as input virtual addresses are aligned for sure

Changes in V2: (https://patchwork.kernel.org/patch/10922795/)

- Replaced WARN_ON_ONCE() with VM_WARN_ONCE() as per Catalin

Changes in V1: (https://patchwork.kernel.org/patch/10921135/)

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: James Morse <james.morse@arm.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Laura Abbott <labbott@redhat.com>

Anshuman Khandual (2):
  mm/ioremap: Check virtual address alignment while creating huge mappings
  arm64/mm: Change offset base address in [pud|pmd]_free_[pmd|pte]_page()

 arch/arm64/mm/mmu.c | 6 +++---
 lib/ioremap.c       | 6 ++++++
 2 files changed, 9 insertions(+), 3 deletions(-)

-- 
2.20.1

