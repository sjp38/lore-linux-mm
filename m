Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25DED83090
	for <linux-mm@kvack.org>; Sat, 27 Aug 2016 05:55:40 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so68030205lfe.0
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 02:55:40 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id a189si11194172lfa.229.2016.08.27.02.55.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Aug 2016 02:55:38 -0700 (PDT)
Subject: Re: [RFC PATCH v3 0/2] arm64/hugetlb: enable gigantic page
References: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
 <20160826102617.GG13554@arm.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <ec6fd8e5-37df-d212-0247-6f9454eafb8e@huawei.com>
Date: Sat, 27 Aug 2016 17:45:45 +0800
MIME-Version: 1.0
In-Reply-To: <20160826102617.GG13554@arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Hi Andrew,
Can this patchset be merged? Or have any other comments?

Thanks
Xie Yisheng

On 2016/8/26 18:26, Will Deacon wrote:
> On Mon, Aug 22, 2016 at 09:20:02PM +0800, Xie Yisheng wrote:
>>
>> Xie Yisheng (2):
>>   mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
>>   arm64 Kconfig: Select gigantic page
>>
> 
> I assume you plan to merge this via -mm/akpm, given that Catalin has
> acked the arm64 part?
> 
Yes, however, it seems still not merged right now.

> Will
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
