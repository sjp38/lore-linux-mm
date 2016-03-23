Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9D58A6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:26:48 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so13079158wml.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 01:26:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si1776382wjx.104.2016.03.23.01.26.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 01:26:47 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56E2FB5C.1040602@suse.cz>
 <20160314064925.GA27587@js1304-P5Q-DELUXE> <56E662E8.700@suse.cz>
 <20160314071803.GA28094@js1304-P5Q-DELUXE> <56E92AFC.9050208@huawei.com>
 <20160317065426.GA10315@js1304-P5Q-DELUXE> <56EA77BC.2090702@huawei.com>
 <56EAD0B4.2060807@suse.cz>
 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
 <56EC0C41.70503@suse.cz> <20160323044407.GB4624@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56F25343.8010100@suse.cz>
Date: Wed, 23 Mar 2016 09:26:43 +0100
MIME-Version: 1.0
In-Reply-To: <20160323044407.GB4624@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lucas Stach <l.stach@pengutronix.de>

On 03/23/2016 05:44 AM, Joonsoo Kim wrote:
>>
>> Fixes: 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated pageblock")
>> Link: https://lkml.org/lkml/2016/3/2/280
>> Reported-by: Hanjun Guo <guohanjun@huawei.com>
>> Debugged-by: Laura Abbott <labbott@redhat.com>
>> Debugged-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: <stable@vger.kernel.org> # 3.18+
>> ---
>>   mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++-------------
>>   1 file changed, 33 insertions(+), 13 deletions(-)
>
> Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Thanks for taking care of this issue!.

Thanks for the review. But I'm now not sure whether we push this to 
mainline+stable now, and later replace with Lucas' approach, or whether 
that approach would be also suitable and non-disruptive enough for stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
