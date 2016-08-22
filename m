Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id C00256B025E
	for <linux-mm@kvack.org>; Sun, 21 Aug 2016 23:00:46 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so190288551pad.2
        for <linux-mm@kvack.org>; Sun, 21 Aug 2016 20:00:46 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id e73si20144788pfj.239.2016.08.21.20.00.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Aug 2016 20:00:46 -0700 (PDT)
From: Xie Yisheng <xieyisheng1@huawei.com>
Subject: [RFC PATCH v2 0/2] arm64/hugetlb: enable gigantic page
Date: Mon, 22 Aug 2016 10:56:41 +0800
Message-ID: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, mhocko@suse.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Arm64 supports different size of gigantic page which can be seen from:
commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
commit 66b3923a1a0f ("arm64: hugetlb: add support for PTE contiguous bit")

So I tried to use this function by adding hugepagesz=1G in kernel
parameters, with CONFIG_CMA=y. However, when I
echo xx > \
  /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
it failed with the following info:
-bash: echo: write error: Invalid argument

This is a v2 patchset which make gigantic page can be used on arm64,
with CONFIG_CMA=y, or other related configs is enable.

You can see the former discussions at:
https://lkml.org/lkml/2016/8/18/310
 
Xie Yisheng (2):
  mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
  arm64 Kconfig: Select gigantic page

 arch/arm64/Kconfig | 1 +
 arch/s390/Kconfig  | 1 +
 arch/x86/Kconfig   | 1 +
 fs/Kconfig         | 4 ++++
 mm/hugetlb.c       | 2 +-
 5 files changed, 8 insertions(+), 1 deletion(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
