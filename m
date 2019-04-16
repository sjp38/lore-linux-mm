Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84043C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:24:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2701A2075B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:24:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2701A2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 856B76B0003; Tue, 16 Apr 2019 07:24:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 808436B0006; Tue, 16 Apr 2019 07:24:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CCC96B0007; Tue, 16 Apr 2019 07:24:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9AD6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:24:56 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id n15so9608600oig.11
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:24:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=+0MSFSzpqmNFd0LZDe9YPp+oCVJ0dVTJnp9rx3oex2Y=;
        b=YhnxFgwYT3zsnOuM2fwHpuShegfzP8eHenSv04Vd1k6KBVKCjuuDRH5A9pz+7ZTldd
         OA7nK9L/MhxxOqKTDDFh6Hhy4BbkjMVTuQQ1dEotZEL1BVEgMceegMd1B3qcWUzp0hBj
         E3G3jLNxB7ysRzn6OzLavtNVla0A5EmK5EYkWf/t36EaryEwgexZOWixgNhQbncd9l0v
         4aWu+D6kJdAwLpXRb/iMG/qAdjRnmlZ7rZPQOzwaD8OknykWTEaOEhqRMjxb7sRJ7dbI
         E35tHm03Qze5T7kY1HSPzXGFPZsdtlpLAHFg9rAaSSAcao3V3MUney3zIPaDNS1e5nzo
         3vGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVT0C+byR6QXy/3ncIw8ISAX+Wdy87T2JRtJ93zh/Oc09n6GxBC
	D1kMLtXNqxqoL2Yeog2XAPAmPMvbgnlqUhRSwYJhoYCzdPMRJS7FO0J/Ngqk8VTQHdzXml59sfo
	iqRbZI/7KtXvtQFYCgd8oVxnhewkMH+7M7a3mMZtCdkO0w7JUpYohKdS9TuoHN+Tvcg==
X-Received: by 2002:a9d:70cc:: with SMTP id w12mr45277232otj.167.1555413895798;
        Tue, 16 Apr 2019 04:24:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxJOD11RBIgywX7im20c+AkkwLyAoAgwNJIbIxcnLaMEbtaCnZFl0deuyoG1UeQSwn0/JU
X-Received: by 2002:a9d:70cc:: with SMTP id w12mr45277206otj.167.1555413894826;
        Tue, 16 Apr 2019 04:24:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555413894; cv=none;
        d=google.com; s=arc-20160816;
        b=SJsOPVO6Ph3ahDhz51EAlhe7ynr+spxpOX2Q7mxh7f8PJBKQzGTc8RDhjekzmtBDms
         uPwf/WjcxHs5tBLuo6wl7r/bXzsPnR7yunUOP4k3UVi/5aEFWhZVgK0ob1H2uEa3RkiH
         RO8aIeAZOe8VctEk3jZt+XYyrnAK1dH015pgWK3cKdLXZ68DxMBvO7L6cwjSQ8OksMXZ
         1ZnjjRp6BWxJa+AwH2YKHVBWCVAcnPGy/T5KTEMHaA9Aehq8MYVWXHV3ZtYNlhcBD3fI
         VOELd9Kq0Yi7ceSRAOe4z5G61CLei1JFGKx91yXMU3ybva+9JaiGLG98MpnQsgbHxvd7
         UWJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=+0MSFSzpqmNFd0LZDe9YPp+oCVJ0dVTJnp9rx3oex2Y=;
        b=srkW92J+FD1EEx6PuakolWkSe3+StdY6PXVnyUHApVxpMrtMSvqvumVoCvE2g6xdOu
         4TKc8niiElWBvWKJgz8E0m+lPbevQejMpdC6Z+J1bLM58lBbxEEsR5JrqXvWsLzCk2QD
         gl7njhCG1JoWXRR9l4U0BXKY4wbCLgBgg1RGRhhFkssyAw76RtWibpVNZ45uJk+Zei+k
         IaDJ0g8mxb4Rr+eMpiDrHdqnePWfSXJVhMjzOk8lsi0R+xc9BqfwuBFX+UlJiR0PAwVC
         9v6yhVSLqitTgxTZwvTBjTEKXRRpOB2CLEItUkmT8A/M4DzCLdu/z3mK6/2QtzK0X/U0
         9gmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id l125si24711372oif.107.2019.04.16.04.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 04:24:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 3EB6F6BD1735FA38CE48;
	Tue, 16 Apr 2019 19:24:49 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS413-HUB.china.huawei.com (10.3.19.213) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 19:24:40 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [RESEND PATCH v5 0/4] support reserving crashkernel above 4G on arm64 kdump 
Date: Tue, 16 Apr 2019 19:35:15 +0800
Message-ID: <20190416113519.90507-1-chenzhou10@huawei.com>
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
- reimplement memblock_cap_memory_ranges for multiple ranges by Mike.

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

Chen Zhou (3):
  x86: kdump: move reserve_crashkernel_low() into kexec_core.c
  arm64: kdump: support reserving crashkernel above 4G
  kdump: update Documentation about crashkernel on arm64

Mike Rapoport (1):
  memblock: extend memblock_cap_memory_range to multiple ranges

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

