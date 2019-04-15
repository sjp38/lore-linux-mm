Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55788C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F5CE20684
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F5CE20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 866E76B0003; Mon, 15 Apr 2019 06:47:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8152D6B0006; Mon, 15 Apr 2019 06:47:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7536A6B0007; Mon, 15 Apr 2019 06:47:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4DC6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:47:00 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id r190so7746335oie.13
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:47:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=MT54N6K7HQkX/UnqgECWKnYhHLDU09h9rRQC7MD3ml4=;
        b=RThsOa+TcVJGfbZD0mzoFrg0f6qnOKUA5uFoxkGGn6chD9lSoQLLHAdAvZz32yJqWR
         eleGWVjEtGU8yFXyTytWVfRRm+xHcPUcOB0MKGDMmXl4MMQ2/zTt5y1dQ/22lJrjlLZf
         4WSmMjrABPQcmjU/EcMkCpN9kd5kDklvlY/sMgyFER/Tb2RXGxrr0fSaIqSmsigbveYu
         xUfFTOxl/QF65AZOy3EYBc4lP8iT88GN1WvEwFYPWqcDqMfZkVwd1SKcl0EHdjPZSerB
         VYVqHS4JwTvMT2vTUZaYZxvsaCb5Jywu68ZJfiSdm9BhAd5aCBeZ+YWwP3144q/zxZDh
         f+RQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAXMju+DJwYd2yC50rLg4gTDM3UboM+empNLW13RVfl9aXD2P1ep
	7l3STMuPSNtva5ejzffxrsD7qEsGGRUaQeev/idBwUhrn5dfmeSH5ZmL5qqMwCDmWREoaQobfZ2
	sCgZgFtet0/DCBdFYxcobCVIfKnk+uY1NJFbI01wk4uYBvTq4xkbF8VwndRL2lij7sw==
X-Received: by 2002:aca:a88c:: with SMTP id r134mr18977468oie.139.1555325219933;
        Mon, 15 Apr 2019 03:46:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4Zur/+3qehe9CL1KplwnP54YcNty3OnKW+mMRkOLJ9bElmyvpYy/bOhEyz3I/mTlrIygW
X-Received: by 2002:aca:a88c:: with SMTP id r134mr18977434oie.139.1555325218919;
        Mon, 15 Apr 2019 03:46:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555325218; cv=none;
        d=google.com; s=arc-20160816;
        b=SsJ32n0fR+KCglrMRuRfNu8/wdTY9y6QOC8EjmGB6R/N33vmuBeyIpLKS+gQ91m2GR
         A18aZ6sqBj5CgofmYxECnIMyuhgXNIRIpsgL+yO5jUz0qWLCl6ghuWmCXeNepMTZSIJF
         QCxHkur8AotsSyPWv7MSdMgf/jUTTkEibznKI2vo+h7qByPp17oe5j+eANW/Ax+TH6yw
         m3gegdyzh46xSOXQ9MA+/RLdcvAVRQ42FKana+1+B2JhdkudHomqiwmEfhgq+oL4cgqo
         MCRcOwNOx5uXsHCZzXA61QREJmBFsIKDNGfp5NCjzLeTfj9ZLjME++bUIQyn0hefqtzo
         zhew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=MT54N6K7HQkX/UnqgECWKnYhHLDU09h9rRQC7MD3ml4=;
        b=XsSFRiHr5wBqmzPL4MLz2T+DDfRTkytn37qTJxFhEYjNYhfX6V9bQ4y1q+2VXo5DYh
         f+J4soqhiy6ir8MWgBrQjUiQkXEX9m20d/OM/R3QEOzJ/lFz0Oa7h3UqQOhF8U4U1pEP
         RF3PhOK5m4GAkPE+usdB9ppU8sgWOMVgGjwWidbAACxxtg7xeZpepAnMLbWTLtOBY7zi
         +TKWYaNbPV5rLHWwu1qrGyfUto77BMg3l1rsLey9NMSOajneVMM8sSgLkBGRZc3JXs6R
         KtC9NHTKnE2F3qGWOzaSkobol+CAo2JvVqVjCND01noEF9EBgTNq4tff1U4SqgMra2gK
         HmAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id u10si22996519otq.246.2019.04.15.03.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 03:46:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 56F919E4758F6FA5716B;
	Mon, 15 Apr 2019 18:46:53 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Mon, 15 Apr 2019 18:46:45 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v4 0/5] support reserving crashkernel above 4G on arm64 kdump 
Date: Mon, 15 Apr 2019 18:57:20 +0800
Message-ID: <20190415105725.22088-1-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When crashkernel is reserved above 4G in memory, kernel should reserve
some amount of low memory for swiotlb and some DMA buffers. So there may
be two crash kernel regions, one is below 4G, the other is above 4G.

Crash dump kernel reads more than one crash kernel regions via a dtb
property under node /chosen,
linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.

Besides, we need to modify kexec-tools:
  arm64: support more than one crash kernel regions(see [1])

Changes since [v3]
- Add memblock_cap_memory_ranges for multiple ranges.
- Split patch "arm64: kdump: support more than one crash kernel regions"
as two. One is above "Add memblock_cap_memory_ranges", the other is using
memblock_cap_memory_ranges to support multiple crash kernel regions.
- Fix some compiling warnings.

Changes since [v2]
- Split patch "arm64: kdump: support reserving crashkernel above 4G" as
  two. Put "move reserve_crashkernel_low() into kexec_core.c" in a separate
  patch.

Changes since [v1]:
- Move common reserve_crashkernel_low() code into kernel/kexec_core.c.
- Remove memblock_cap_memory_ranges() i added in v1 and implement that
  in fdt_enforce_memory_region().
  There are at most two crash kernel regions, for two crash kernel regions
  case, we cap the memory range [min(regs[*].start), max(regs[*].end)]
  and then remove the memory range in the middle.

[1]: http://lists.infradead.org/pipermail/kexec/2019-April/022792.html
[v1]: https://lkml.org/lkml/2019/4/8/628
[v2]: https://lkml.org/lkml/2019/4/9/86
[V3]: https://lkml.org/lkml/2019/4/15/6

Chen Zhou (5):
  x86: kdump: move reserve_crashkernel_low() into kexec_core.c
  arm64: kdump: support reserving crashkernel above 4G
  memblock: add memblock_cap_memory_ranges for multiple ranges
  arm64: kdump: support more than one crash kernel regions
  kdump: update Documentation about crashkernel on arm64

 Documentation/admin-guide/kernel-parameters.txt |  4 +-
 arch/arm64/include/asm/kexec.h                  |  3 ++
 arch/arm64/kernel/setup.c                       |  3 ++
 arch/arm64/mm/init.c                            | 59 ++++++++++++++++------
 arch/x86/include/asm/kexec.h                    |  3 ++
 arch/x86/kernel/setup.c                         | 66 +++----------------------
 include/linux/kexec.h                           |  5 ++
 include/linux/memblock.h                        |  2 +-
 kernel/kexec_core.c                             | 56 +++++++++++++++++++++
 mm/memblock.c                                   | 56 +++++++++++++++------
 10 files changed, 166 insertions(+), 91 deletions(-)

-- 
2.7.4

