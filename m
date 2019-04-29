Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84F0DC004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BF062147A
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BF062147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC7936B0003; Mon, 29 Apr 2019 13:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D78CA6B0005; Mon, 29 Apr 2019 13:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C68D96B0007; Mon, 29 Apr 2019 13:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB166B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:22:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f41so5170894ede.1
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:22:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=r5JWD3nqhrvd9gBlN4YP9MLGFW9QDnQR79076BvfFC8=;
        b=uShrA24QyLuEr+TE1gIGSy4hehc2rVtxkECDjnvYNW0RpIAxHgtlD/X3ayhhCQNCxZ
         EB9F93Ge0qp9WvDoAOjN71m1tp1FoVtHFvn7YlARRfrsNOT90HOhMKkL9chKKBiHiUrR
         9SPbIYT0s7PW44U4uRSsWbvwTpWMiYhUKXYebVhdeCiR4gKOYjelFcnT6ho1fiSqEWR2
         CWWjdsKt4jCx50ym0Om51riJkNj6JhhgNSETHIoZdszVVl/eOextqSRO+wd3+vJAKqVm
         cCLkPL3zglMkNqcDvsnAT3vgUjBVFaszccEi8XS1xnW7uZuWuuhpEBvQEgqoGdsoy2U9
         UmAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAUnK1POH34BmoYdt/9SXX6+bHP8C2UBzEY6u0RywtaDeX+G+ghr
	PEWAOQqew8a6XkbcrC33leZQcQCn4MbRHNSPhpNJFUJXEsoREZ7szUqdBnQUGYz0/RyevJTWyFt
	TObg013oVtTjbJIWPRmvFSCCpTtCjOf/xJcEvYvGH0d2l2G86X84Ksa1ONDUiyTuzDA==
X-Received: by 2002:aa7:c483:: with SMTP id m3mr5668177edq.161.1556558547108;
        Mon, 29 Apr 2019 10:22:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyz89B4GZuT0UKVu75fecxDG8boXDphRVSidouTaoYCb8qh0oopDzy1GHl15ERzyebGCfdH
X-Received: by 2002:aa7:c483:: with SMTP id m3mr5668130edq.161.1556558546295;
        Mon, 29 Apr 2019 10:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556558546; cv=none;
        d=google.com; s=arc-20160816;
        b=Zh2CDqka2qsjojb4Fehq+hPzsORJA/mbWwNgWTdZsMZ9QypDtTCNqixX7+IV+5Rpjg
         W3JxQYUfa7cWEQu2nX29NIX0IV5CMIYVv3YDZpHqFDnBALDQrTCNUcat6vxmWSToqQrx
         4siFM2UuebhpnKs4tgTOVn4K0AC3Ax50c9kX6vFmTWPDnrX1m/8dh7L+JDKagb/RkbQz
         Zuj96KP4bT57xyIg1+H/ocfpxR7ScB/+lHiPWNPuxwWxaZdM3Zi2l9UOg7Q0kOrshPrJ
         LGiXwY/AQ//a+3eV29j8L+GaIzXt73ZHzatkLVIRo+7g3XdKoSgx26bVcqG7q8ox0Jsl
         l8qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=r5JWD3nqhrvd9gBlN4YP9MLGFW9QDnQR79076BvfFC8=;
        b=t1WkU2LMWpyo7dfo1KB4VzI+SrJ7gx7uYDSSNUcE8iewJ9OxWFbVecIwcIwf0YxOzJ
         UcEgB5q3sq/lDUWclvknK8hKrxUIkK6uJCtegg0W/7MRjC2cZifvS3TleNY4M7gODiao
         i07CYXYV5o3O7pLkNaPDyhTMoKRC2PyYG4ajXTRBLt7Z74UER0l6Ezzart0kgInhxwPY
         xzM8wLE8S1uWeAmKMCk/lmsVTKuxvzkbneUnMY0Py1P8dChkyhqGwmDSZACeTTwI1I7/
         1JbfOISndj9bf59S/phxvxNAbYZ4JBpSkiF4nU8+9asr/VFhcs9LHYfCWNaKrRKLIfNz
         TmLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v6si227364eji.277.2019.04.29.10.22.26
        for <linux-mm@kvack.org>;
        Mon, 29 Apr 2019 10:22:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 40EC480D;
	Mon, 29 Apr 2019 10:22:25 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 5D4BA3F557;
	Mon, 29 Apr 2019 10:22:24 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 0/3] Device-memory-related cleanups
Date: Mon, 29 Apr 2019 18:22:14 +0100
Message-Id: <cover.1556555457.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

This is essentially just a repost, with the trivial typo fix plus all
the acks/reviews collected. There's no direct dependency between the
patches here, so hopefully at least #1 and #3 might sneak into 5.2 if
there's still time, as that would save some bother for follow-up arm64
work next cycle which will depend on both.

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

