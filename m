Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 400E2C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:33:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFA3D20868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:33:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFA3D20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72EE96B0007; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DFCA6B0008; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F4F56B000A; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB7C6B0008
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id i203so9362438oih.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 00:33:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=0e/Kik8QKptIKPHVVpP81WoAaJgyAjI4Sa78KHNZsw8=;
        b=NTGJBThKINHJzVsXzLnl19VoCYHyeoXdlIZwT0Qd/kzYOv1bpezIB0nCGYoD1lU6s7
         j2KVVmIU8Gha5H9WpwbHn8TS9zMEEladyavnoOsbnTvQFB5P4kbGZVpMd1ASMsBX/Sw+
         Asiq5cISVoGUvCsuo6jWQahXCiDOkX8DvkPzP0BEjJxwaTHlfqgkyAIcN1SgRiXxhq1v
         X7WXO3fgAIfVnL5a1MQ/UEQroTCjD9n7Z2Zrf9MFxDXdAELg1MNOzdkDw9Jja6J5cvd6
         RllbTF2I3fQQ8PZQoGbol420XX83PTTHO7ezQk7od876r5OOf3ImUvIwcFiVZPHPuHZ5
         BOTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUf8mydDpNNdzMrsRFixSSEMGsI8utAsvhyN9SuMBxC4ci/pRi+
	IjRlOCev9kxovNMeTSe0p2kXbAEcA5qMKc/hou9XPCZKTdBVp6cHyDvO5LrKlVp7+OpCLplQuh/
	RRYCoII6VIjQ8yw6JaeAREavgF/QNm+IZMQRCWsw+B5b3PwFDHgLwx0tn9uG95r4WhQ==
X-Received: by 2002:aca:b7c5:: with SMTP id h188mr15829511oif.130.1555400015833;
        Tue, 16 Apr 2019 00:33:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxm19mLjKtEsvsYha6uj2P4BnHD2DSYUWMIl+a415AyTmvQlHTh1xVZJQjrihxt+Me81i7v
X-Received: by 2002:aca:b7c5:: with SMTP id h188mr15829476oif.130.1555400014925;
        Tue, 16 Apr 2019 00:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555400014; cv=none;
        d=google.com; s=arc-20160816;
        b=Ffqs8ITTf67tOtBGdAA19RkewQhelmMzvtGOUUxK68WonI0yHo5ZKhUhd4s2CGpRbF
         siRbGMVQ1DPSxhLJKnknywMT37Un8FvtDZ/aMowkSmqWrIUTMViNB8UBqQflfWYifFse
         2FQo5F//YLfvPY8dp4nRHtqczS8CwqCDO1D6qt9+h9HDW2JwyNEthUfODgK1PS5JB7kl
         v9/O8+dJvjQ6/eATDmDChiOXyIYEcHn3hTUVjPdyYOtgpFkqr2vdYRTb6zjJ55nXkq4C
         xbedqeOKuRgBXEsWaiZA0fhI76XqqC759QloRMR+1VqQzncBcdSNjgqFrVeoIWXEaD3j
         SFgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=0e/Kik8QKptIKPHVVpP81WoAaJgyAjI4Sa78KHNZsw8=;
        b=U0B6vb1uoKT9DuQTrNUGTK8niNpxv4BY8U8HnEa92ENcRvKqIQyl3chcpDNQDvTuma
         Fzii+DkeQ4bqFSHTSm1QvcW4RMKaK2v4Y6LX2PLjpnRBiWF1KRbPX6ccQHMnBz7zaqsz
         i2IYTqMTUVIIhUiWCs1QDAb2FDaYNnS8KmxSzgyECbyeoTtk1rP6CEFm/NOPU9tWMoXX
         ci14fCBNz33pCowKUoyqZSqzw2MCwpkkE7OW80HLOa81HhbQm/x5WqedfffHoP3sHMdv
         W0CZcdKFFrA14WP5P1YUrCAZ0zClzGGOs9BXoR6Zx7HpAEO8FfV29ETWl4aairvPFvig
         sIUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id r4si24799713oti.316.2019.04.16.00.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 00:33:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 13A0EA6391B7F7874980;
	Tue, 16 Apr 2019 15:33:14 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 15:32:55 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v5 0/4] support reserving crashkernel above 4G on arm64 kdump  
Date: Tue, 16 Apr 2019 15:43:25 +0800
Message-ID: <20190416074329.44928-1-chenzhou10@huawei.com>
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

Changes since [v4]
- reimplement memblock_cap_memory_ranges for multiple ranges.

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
[v3]: https://lkml.org/lkml/2019/4/15/6
[v4]: https://lkml.org/lkml/2019/4/15/273

Chen Zhou (4):
  x86: kdump: move reserve_crashkernel_low() into kexec_core.c
  arm64: kdump: support reserving crashkernel above 4G
  memblock: extend memblock_cap_memory_range to multiple ranges
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
 mm/memblock.c                                   | 44 ++++++++---------
 10 files changed, 144 insertions(+), 101 deletions(-)

-- 
2.7.4

