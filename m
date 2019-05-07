Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D531EC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F7D420835
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F7D420835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37C946B0005; Mon,  6 May 2019 23:42:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32C2B6B0006; Mon,  6 May 2019 23:42:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F5216B0007; Mon,  6 May 2019 23:42:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC1C16B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 23:42:11 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 18so5282767otu.0
        for <linux-mm@kvack.org>; Mon, 06 May 2019 20:42:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=nkSEtngruEPgV7UOd57ZmxJxTXxp73Kn+Vlqw0twJIw=;
        b=EpaX1Fw9MPIbPANBjUchrYDRIiQIjvaBVp9c0Q6Uho/FZ1lr8ZXLofECIzVlBp/2SM
         D2UdkFzfyVU1It8enAkK6Knk4iOCtnjWz5rBfTsExM9k+/L+OxrnVOuSXyq21r9b4reI
         jbwPZwJvS7fAxmQy3DOfrgG6Kdwq8YR0jNaMUJCXx+bqmvFiWVL6XpdNAVTt4c9DEeUi
         dew89OKFd6gOicJMMG1zYT5beTCQnPJK3AnRepCNQawfMhdYuzPxkoFL7FSbQy/XMYKd
         kjWJLQvKuFaETO4C9xLrG6iRnEDOgeKJHfMTW7y3PEcGuCtDyL6+1cuQ7srbO/20Ll0v
         2X1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAXMcARJr8sO+jOLKglVL1vKkwDWZl4xqpYeGsRwJ2y368Kx9pIj
	2vr3kA5BSwtLTdQ2rkfMMJ8qdn3ENKlPg54kB+ez8iwf8VGm5SMlNVftf7TYOgWDuiVtK6ijfCE
	qvvNZMlNujEFSo71u4368R79ZlYhkv3uPYGYN3k8TA5wHw1XJACwJhM5tUTuQalRwSw==
X-Received: by 2002:a9d:6b93:: with SMTP id b19mr21335498otq.313.1557200531648;
        Mon, 06 May 2019 20:42:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMZmAlEFuOVvi6NFxbBcoS3V8wnfMDp8InhwbcTR+Hp7WVD7UEPW10MQBNY0m9mcRQzp6Y
X-Received: by 2002:a9d:6b93:: with SMTP id b19mr21335466otq.313.1557200530869;
        Mon, 06 May 2019 20:42:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557200530; cv=none;
        d=google.com; s=arc-20160816;
        b=pOt1eZYjAT5d4xGorF2BMK4dJBV16wGrIl+LQq8sP3v8GXWTE+3GzoJV58rO+VkTbF
         nVUIpWhPZpDDDOMIcH1F4Ljvgip0Oa4Pt1VI53xTOF2TRRto6cCFH1wvFGkQUEW5yana
         nVYVNCdXFapUY1HxjPNVh5NRjcaP08NmpXYvnTKEpybGVhrZsrA+JTf9izDWa05Z97IS
         LARWv52XFEcObtncrEUatpEcsI9r//MbHlUvHprvvP0p84ESTkF0I8PsCB/gfy8MgtJi
         /OsOoE5p1iT+n2SxUJb5wMh8eHF88tWNET1xNIea2KMLO/bOSCBpritoBwdd6D47TFio
         IixA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=nkSEtngruEPgV7UOd57ZmxJxTXxp73Kn+Vlqw0twJIw=;
        b=gfDTaP6bE5LyHGSGew1r8Raf6omzCX+os00OHMJH0nXkAaz5L7per+id7KfkWtUS5w
         lYvNn5xYaGctolTpl99w8InuLpQ2LQH4UJ5xHAeHbiZ+sK3e515h6FQ0wo6HA0CX0mOB
         1gSpDTTRj2eTGhqJOpxIwlY9HWBYnav/pbs4uld8EJ+xGjqgG48mY1ZDQfzeJVXdbXxQ
         HFfxhi19sF4uzLa80pCvCK2sRiLjCjYL9uyktT6d8cQNOLEoT+5JxvFaPjdGPa2FDP79
         hqFZDxMU4WXa02eU5eKcNTpujUYQN1YA90828b1cgxdPGwM96W6Sl1rFV7UuE6PqFcdX
         zsig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id q3si7559446oig.166.2019.05.06.20.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 20:42:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 44A7083ABDF68C9C0024;
	Tue,  7 May 2019 11:42:05 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS403-HUB.china.huawei.com (10.3.19.203) with Microsoft SMTP Server id
 14.3.439.0; Tue, 7 May 2019 11:41:55 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 0/4] support reserving crashkernel above 4G on arm64 kdump 
Date: Tue, 7 May 2019 11:50:54 +0800
Message-ID: <20190507035058.63992-1-chenzhou10@huawei.com>
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

This patch series enable reserving crashkernel on high memory in arm64.

We use crashkernel=X to reserve crashkernel below 4G, which will fail
when there is no enough memory. Currently, crashkernel=Y@X can be used
to reserve crashkernel above 4G, in this case, if swiotlb or DMA buffers
are requierd, capture kernel will boot failure because of no low memory.

When crashkernel is reserved above 4G in memory, kernel should reserve
some amount of low memory for swiotlb and some DMA buffers. So there may
be two crash kernel regions, one is below 4G, the other is above 4G. Then
Crash dump kernel reads more than one crash kernel regions via a dtb
property under node /chosen,
linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.

Besides, we need to modify kexec-tools:
  arm64: support more than one crash kernel regions(see [1])

I post this patch series about one month ago. The previous changes and
discussions can be retrived from:

Changes since [v4]
- reimplement memblock_cap_memory_ranges for multiple ranges by Mike.

Changes since [v3]
- Add memblock_cap_memory_ranges back for multiple ranges.
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
[v1]: https://lkml.org/lkml/2019/4/2/1174
[v2]: https://lkml.org/lkml/2019/4/9/86
[v3]: https://lkml.org/lkml/2019/4/9/306
[v4]: https://lkml.org/lkml/2019/4/15/273

Chen Zhou (3):
  x86: kdump: move reserve_crashkernel_low() into kexec_core.c
  arm64: kdump: support reserving crashkernel above 4G
  kdump: update Documentation about crashkernel on arm64

Mike Rapoport (1):
  memblock: extend memblock_cap_memory_range to multiple ranges

 Documentation/admin-guide/kernel-parameters.txt |  6 +--
 arch/arm64/include/asm/kexec.h                  |  3 ++
 arch/arm64/kernel/setup.c                       |  3 ++
 arch/arm64/mm/init.c                            | 72 +++++++++++++++++++------
 arch/x86/include/asm/kexec.h                    |  3 ++
 arch/x86/kernel/setup.c                         | 66 +++--------------------
 include/linux/kexec.h                           |  5 ++
 include/linux/memblock.h                        |  2 +-
 kernel/kexec_core.c                             | 56 +++++++++++++++++++
 mm/memblock.c                                   | 44 +++++++--------
 10 files changed, 157 insertions(+), 103 deletions(-)

-- 
2.7.4

