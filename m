Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9216B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:30:27 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l187so50976733oia.0
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:30:27 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id i40si12937074otd.114.2016.09.30.02.30.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 02:30:22 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v4 0/2] arm64/hugetlb: enable gigantic page 
Date: Fri, 30 Sep 2016 17:26:07 +0800
Message-ID: <1475227569-63446-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

changelog
=========
v3->v4:
add changelog in the cover leter to make the change history more clear.

v2->v3:
change the Kconfig file to avoid comile warning when select
ARCH_HAS_GIGANTIC_PAGE with !CONFIG_HUGETLB_PAGE

v1->v2:
introduce the ARCH_HAS_GIGANTIC_PAGE as Michal Hocko <mhocko@suse.com> suggested

Arm64 supports different size of gigantic page which can be seen from:
commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
commit 66b3923a1a0f ("arm64: hugetlb: add support for PTE contiguous bit")

So I tried to use this function by adding hugepagesz=1G in kernel
parameters, with CONFIG_CMA=y. However, when I
echo xx > \
  /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
it failed with the following info:
-bash: echo: write error: Invalid argument

This is a v4 patchset which make gigantic page can be
allocated and freed at runtime for arch arm64,
with CONFIG_CMA=y or other related configs is enabled.

You can see the former discussions at:
https://lkml.org/lkml/2016/8/18/310
https://lkml.org/lkml/2016/8/21/410
https://lkml.org/lkml/2016/8/22/319

Yisheng Xie (2):
  mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
  arm64 Kconfig: Select gigantic page

 arch/arm64/Kconfig | 1 +
 arch/s390/Kconfig  | 1 +
 arch/x86/Kconfig   | 1 +
 fs/Kconfig         | 3 +++
 mm/hugetlb.c       | 2 +-
 5 files changed, 7 insertions(+), 1 deletion(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
