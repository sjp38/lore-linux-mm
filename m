Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 827FDC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:02:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C04E20818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:02:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C04E20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2F936B000C; Fri, 12 Apr 2019 15:02:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE6476B000D; Fri, 12 Apr 2019 15:02:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCD566B0010; Fri, 12 Apr 2019 15:02:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3B76B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 15:02:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f7so5490125edi.3
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:02:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=F7Cv9el9g/ZJ9E6s2DQXpeg6eDbbzVxRpHlfCN7fnKY=;
        b=nBcxl7HhUJPTbMBHbuaF8Ihb9WaVw2WgXFgwPk40PYnSLVcbHrFYLe6j3Ec5pznsoC
         M2C9fK1S9Nd4qgvBB2uSsGJAMZmUQ41iDCbppoxcfTkvrjfecwPXe3vd4Kq4uTThfmuk
         d3pljUUDuEUfsrVQKvMpDGEoR1MKjTCpoG7woB9p174GnFh3qwhu9zfsE9r5tbJxN1wR
         K+2NBSg4pnGA+WfdbRqqz+ZhXhBwnJwfBgQkXpvIByCQ/sMPIsBjpsSFoohpMJHhWqtS
         aL071DC3an17uuGSMIZIglpUj0PHTLR5qocBeciKCmcEkiTNvubL4uhuU/u4uwuHNc6F
         FZbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWqeeTrZjWm7ZpCpYDF4ef4ZyKe3bk6tQ1te1GyX6+C0O9/Skiw
	2O4L/04fEiHnTUPdi0Y+RZzEekcJbdNwP547p+2JaM2FDU7iju+4Z8YRrhaKJ/xrzW+gNIexhj0
	ClTbAkKURF9xoh51QsntCq2Q20VWpqiR21VjYO3cw5BLguRxolOXOKZB/CDwVRUEo/w==
X-Received: by 2002:a50:e61a:: with SMTP id y26mr23069305edm.157.1555095725998;
        Fri, 12 Apr 2019 12:02:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOUolFGbLlSyuZsuhgds/EwjZGkgveR/HBGB1WrZmX0QreMz+WJu7bHQ3+rKtThAFGVaCs
X-Received: by 2002:a50:e61a:: with SMTP id y26mr23069261edm.157.1555095725193;
        Fri, 12 Apr 2019 12:02:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095725; cv=none;
        d=google.com; s=arc-20160816;
        b=Xu/WgFxbMINvFDLgDmC6yvF+Nc+hslQSwSwFM5NY0dXejXJLctAs7ps4W01cbArbKq
         HYISoHjuzeTIAtzDCo8YYQLX3JvkU4rc8pxhf2w+VD4/15fwdwi9Q4NMWNGmjxhXZNhX
         qOAp+wBJuRXZ4GVAhhWOObtjamQSGs57J6nkFgdYTIi8YVdk9f0bCS+BCQk/4rW3VJuL
         tL0Z+yPFOGd48txen7hKDY5atO5NEohcP9y0PUk/Rrj2f7DnU1JCUhsohT+amYYDK9sI
         IBANrOfU8M0qCjMdJ3X0FRaRutkjDPPaOvpnOwUlt45KDcYcIBbOMLs3CFamvbrxZDkC
         BfPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=F7Cv9el9g/ZJ9E6s2DQXpeg6eDbbzVxRpHlfCN7fnKY=;
        b=mqqzk+twyMC+oC38vFwl/zv87Q+VmNQm1kz7cWG8EVZgGejcQXSEkgP/3Eb9jG6ast
         IDQ/0jyieBUgkNktKngF3tmRzxebHLdSwM/EfMnXtIL8WzEcQu8QfDuWteIJlEGgJcqe
         /zn8s2PCwgIDepaxHp6hH4vfnQD4KUevlRwhxSOyb1SVe9vvEgDsdNTEw+Hl7XuBdAMo
         PRjwSAZZ63fUH5DgDrct5tsnJy1QIGXpocm9p34l4VQOsGz/EVprytjiljYf64CjR8Na
         4xLnmlqas1aKtg5zxO8m77mZJfWmqTtINeCzpteu4lclQXmDf8WxTKKXS4QRPZHN4UED
         +yNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y24si4557834ejo.327.2019.04.12.12.02.04
        for <linux-mm@kvack.org>;
        Fri, 12 Apr 2019 12:02:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EE618374;
	Fri, 12 Apr 2019 12:02:03 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 4F8043F718;
	Fri, 12 Apr 2019 12:02:02 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: dan.j.williams@intel.com,
	ira.weiny@intel.com,
	jglisse@redhat.com,
	oohall@gmail.com,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH RESEND 0/3] Device-memory-related cleanups
Date: Fri, 12 Apr 2019 20:01:55 +0100
Message-Id: <cover.1555093412.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190412190155.kci2l3S-CQx2M0GZ-555dnlNtJMN0GaxAkZ4efe74mE@z>

[This time hopefully without botching Oliver's address.. sorry for the spam]

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

