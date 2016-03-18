Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 672B8828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 08:29:32 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id p65so66613608wmp.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 05:29:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ju3si15832227wjb.228.2016.03.18.05.29.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 05:29:31 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56EBF4A6.5010308@suse.cz>
Date: Fri, 18 Mar 2016 13:29:26 +0100
MIME-Version: 1.0
In-Reply-To: <20160317065426.GA10315@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hanjun Guo <guohanjun@huawei.com>
Cc: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/17/2016 07:54 AM, Joonsoo Kim wrote:
> On Wed, Mar 16, 2016 at 05:44:28PM +0800, Hanjun Guo wrote:
>> On 2016/3/14 15:18, Joonsoo Kim wrote:
>>
>> Hmm, this one is not work, I still can see the bug is there after applying
>> this patch, did I miss something?
>
> I may find that there is a bug which was introduced by me some time
> ago. Could you test following change in __free_one_page() on top of
> Vlastimil's patch?
>
> -page_idx = pfn & ((1 << max_order) - 1);
> +page_idx = pfn & ((1 << MAX_ORDER) - 1);

I think it wasn't a bug in the context of 3c605096d31, but it certainly Does 
become a bug with my patch, so thanks for catching that.

Actually I've earlier concluded that this line is not needed at all, and can 
lead to smaller code, and enable even more savings. But I'll leave that after 
the fix that needs to go to stable.

> Thanks.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
