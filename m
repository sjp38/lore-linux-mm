Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 723A76B0260
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 09:25:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i64so152144690ith.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:25:14 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id c204si10470960oig.78.2016.08.22.06.24.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 06:25:13 -0700 (PDT)
From: Xie Yisheng <xieyisheng1@huawei.com>
Subject: [RFC PATCH v3 0/2] arm64/hugetlb: enable gigantic page
Date: Mon, 22 Aug 2016 21:20:02 +0800
Message-ID: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
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

This is a v3 patchset which make gigantic page can be
allocated and freed at runtime for arch arm64,
with CONFIG_CMA=y or other related configs is enabled.

You can see the former discussions at:
https://lkml.org/lkml/2016/8/18/310
https://lkml.org/lkml/2016/8/21/410
 
Xie Yisheng (2):
  mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
  arm64 Kconfig: Select gigantic page

 arch/arm64/Kconfig | 1 +
 arch/s390/Kconfig  | 1 +
 arch/x86/Kconfig   | 1 +
 fs/Kconfig         | 3 ++++
 mm/hugetlb.c       | 2 +-
 5 files changed, 7 insertions(+), 1 deletion(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
