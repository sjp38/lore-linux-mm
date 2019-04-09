Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 332D9C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0DED20830
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:30:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0DED20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3164A6B000D; Tue,  9 Apr 2019 06:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EB756B0010; Tue,  9 Apr 2019 06:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2025C6B0266; Tue,  9 Apr 2019 06:30:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC7D56B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:30:28 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id w11so9643193otq.7
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=jwI1StMgIsnE0cAW6qX6SjVPmfs/b6UNzNgGTT/RmL8=;
        b=fIfSu0EPMPouyJ7gd40kvu1Jj6f+nFfTXLYnTgfapX5ADyfqSXtwVZ3NSC0v9uEF5i
         Xa23JcfIO64XO7NBd+s94ByW4Q85TcUlTuwiTMtJq3kGKTixuUbBtlOjM/h8+FCmZ/Jh
         YaaoPfOdOKB0Zu+0OHZVxyaTY1HMejDbvX2XAxbFrFRFIItWXMdn9Y/Y4XduSsXW0whs
         DJZsExgTqTCQMRm6K2ebaKNsELYpm2qmpJJtCAbQ8SroK3lt883hr7gjmaB9beLZl5a1
         6lkZoYr7FIXvv7mQnKgJIcQffJzWzlTQj2FLRZUC268G9VULkWtkNkqObSEAejXSHQzq
         /wJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAV9NQw0Y7UxFW49zTExlK2SFAbdaN//GAcTM4qPU8tDKhAcXu3b
	yD1fbkIvb4dooME4Ykjo+NCdqqX21hZ956qgeqDxlsQby3kYv9L1PsTIavzluYtsyMyNEyALmfK
	WuXlsbLhGE5GH2Pn5C9I4IDdVoB2+Da05kdsEswMzzLivLuBh/AivmPYCihtQGBDZYQ==
X-Received: by 2002:a9d:3de5:: with SMTP id l92mr23906436otc.200.1554805828606;
        Tue, 09 Apr 2019 03:30:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaL7QmAK06ht1hxhQnCPErFy6R6v2ddRkhhgaogI/34T8ZV/b6s7DsfaxGMQfokH0rDU/K
X-Received: by 2002:a9d:3de5:: with SMTP id l92mr23906388otc.200.1554805827809;
        Tue, 09 Apr 2019 03:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554805827; cv=none;
        d=google.com; s=arc-20160816;
        b=PDf4b9CJEA2njPynJ4fWVBPUv30Nj36n0kYNfTVF3K9GhZqRwEMqIOtxulHygeQl5G
         tmhkw6Aan082MiGvHgs/CeeOcjQRyLmrTSobRAG7JVrEurTjDFB0hdZGSwDcXoRay8MI
         reo/TzUr/gGoCzqqbzsSp5R1z7jFrTbcJI5nX9dsQQLoE4w8VR6FpOsRrR+QivzQaoDo
         zlFEBiIQ3LaBD9F9DYippmmhKCE0VJic0zQYpKYkcGoOIUO++iPUuQk7d2NRhxIE1/rJ
         MV1DVYMO3jvAHd3H+jbkjsqoKQ/zTTvW/Nt5sGSC/ly3K0jcuUijmdMHDZt2SAmbktOD
         kawg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=jwI1StMgIsnE0cAW6qX6SjVPmfs/b6UNzNgGTT/RmL8=;
        b=Gh0dSQpSkhw5nJAEDxrAXgUgZ1alZW1z6rkCEZsH58vvIU80AXjkIurDS+lu/iDcb+
         JxLxF2iMwhdK8UVkM2vWd2GRwYMwu3Q1SC33tt2Uztxc2vuRU+bbZTjxkZnuDP6aeWRs
         xSLoewY+ERbrttgwxbyD4MlxFDkDpljZgDdUwwg9gJo7+69tqB0hYW4zfLit5oZc/klq
         R6W+qapFIB4HiZcMVelf+AnbZQ1AoFNwleUTd8xIByUeU+/57LAfiuXhOBy/azmhLxaE
         c7DwGwtIEc4AFDHg+SuztwMKdq5skmdwg9+yOxnOWkI256v8jnnu4L2CjaWUs2EI0bLC
         tDoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id v187si14732675oie.263.2019.04.09.03.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 3B36332E131E4A5A35B3;
	Tue,  9 Apr 2019 18:17:26 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 18:17:19 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v3 0/4] support reserving crashkernel above 4G on arm64 kdump
Date: Tue, 9 Apr 2019 18:28:15 +0800
Message-ID: <20190409102819.121335-1-chenzhou10@huawei.com>
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

Changes since [v2]
- Split patch "arm64: kdump: support reserving crashkernel above 4G" as
  two. Put "move reserve_crashkernel_low() into kexec_core.c" in a seperate
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

Chen Zhou (4):
  x86: kdump: move reserve_crashkernel_low() into kexec_core.c
  arm64: kdump: support reserving crashkernel above 4G
  arm64: kdump: support more than one crash kernel regions
  kdump: update Documentation about crashkernel on arm64

 Documentation/admin-guide/kernel-parameters.txt |  4 +-
 arch/arm64/include/asm/kexec.h                  |  3 +
 arch/arm64/kernel/setup.c                       |  3 +
 arch/arm64/mm/init.c                            | 92 +++++++++++++++++++++----
 arch/x86/include/asm/kexec.h                    |  3 +
 arch/x86/kernel/setup.c                         | 66 ++----------------
 include/linux/kexec.h                           |  1 +
 include/linux/memblock.h                        |  6 ++
 kernel/kexec_core.c                             | 53 ++++++++++++++
 mm/memblock.c                                   |  7 +-
 10 files changed, 159 insertions(+), 79 deletions(-)

-- 
2.7.4

