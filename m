Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9EEC6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 07:43:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so191114561pfg.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:43:54 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id p186si22491168pfg.281.2016.08.22.04.43.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 04:43:54 -0700 (PDT)
Subject: Re: [RFC PATCH v2 2/2] arm64 Kconfig: Select gigantic page
References: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
 <1471834603-27053-3-git-send-email-xieyisheng1@huawei.com>
 <20160822080358.GF13596@dhcp22.suse.cz>
 <20160822100045.GA26494@e104818-lin.cambridge.arm.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <b5f1f756-4698-4c32-1c30-97b1ccf2b4a6@huawei.com>
Date: Mon, 22 Aug 2016 19:33:46 +0800
MIME-Version: 1.0
In-Reply-To: <20160822100045.GA26494@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Michal Hocko <mhocko@kernel.org>
Cc: mark.rutland@arm.com, linux-mm@kvack.org, sudeep.holla@arm.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, robh+dt@kernel.org, guohanjun@huawei.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com



On 2016/8/22 18:00, Catalin Marinas wrote:
> On Mon, Aug 22, 2016 at 10:03:58AM +0200, Michal Hocko wrote:
>> On Mon 22-08-16 10:56:43, Xie Yisheng wrote:
>>> Arm64 supports gigantic page after
>>> commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
>>> however, it got broken by 
>>> commit 944d9fec8d7a ("hugetlb: add support for gigantic page
>>> allocation at runtime")
>>>
>>> This patch selects ARCH_HAS_GIGANTIC_PAGE to make this
>>> function can be used again.
>>
>> I haven't double checked that the above commit really broke it but if
>> that is the case then
>>  
>> Fixes: 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at runtime")
>>
>> would be nice as well I guess. I do not think that marking it for stable
>> is really necessary considering how long it's been broken and nobody has
>> noticed...
> 
> I'm not sure that commit broke it. The gigantic functionality introduced
> by the above commit was under an #ifdef CONFIG_X86_64. Prior
> to that we had a VM_BUG_ON(hstate_is_gigantic(h)).
> 
Hi Catalin and Michal ,
Thank you for your reply.
Before that commit gigantic pages can only be allocated at boottime and
can't be freed. That why we had VM_BUG_ON(hstate_is_gigantic(h)) in
function update_and_free_page() Prior to that.

Anyway, it should not just add #ifdef CONFIG_X86_64 for arm64 already
supported 1G hugepage before that commit. Right?

Please let me know if I miss something.

Thanks
Xie Yisheng.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
