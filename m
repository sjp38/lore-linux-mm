Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F43A6B0253
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:43:49 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu14so189443603pad.0
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:43:49 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id vw1si19285899pac.278.2016.09.30.02.43.46
        for <linux-mm@kvack.org>;
        Fri, 30 Sep 2016 02:43:47 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1475227569-63446-1-git-send-email-xieyisheng1@huawei.com> <1475227569-63446-3-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1475227569-63446-3-git-send-email-xieyisheng1@huawei.com>
Subject: Re: [PATCH v4 2/2] arm64 Kconfig: Select gigantic page
Date: Fri, 30 Sep 2016 17:43:26 +0800
Message-ID: <00d101d21aff$188a86c0$499f9440$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Yisheng Xie' <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Friday, September 30, 2016 5:26 PM Yisheng Xie wrote
> 
> Arm64 supports gigantic page after
> commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
> however, it can only be allocated at boottime and can't be freed.
> 
> This patch selects ARCH_HAS_GIGANTIC_PAGE to make gigantic pages
> can be allocated and freed at runtime for arch arm64.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
