Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 297256B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:42:38 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 124so64766452itl.1
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:42:38 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id a63si21462108ioj.7.2016.09.30.02.42.11
        for <linux-mm@kvack.org>;
        Fri, 30 Sep 2016 02:42:13 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1475227569-63446-1-git-send-email-xieyisheng1@huawei.com> <1475227569-63446-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1475227569-63446-2-git-send-email-xieyisheng1@huawei.com>
Subject: Re: [PATCH v4 1/2] mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
Date: Fri, 30 Sep 2016 17:41:52 +0800
Message-ID: <00d001d21afe$e08df220$a1a9d660$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Yisheng Xie' <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Friday, September 30, 2016 5:26 PM Yisheng Xie
> 
> Avoid making ifdef get pretty unwieldy if many ARCHs support gigantic page.
> No functional change with this patch.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
