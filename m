Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id C768D6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:32:44 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id ts10so5930083obc.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 01:32:44 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id c22si667491otd.226.2016.03.23.01.32.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 01:32:44 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id r187so9976012oih.3
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 01:32:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56F25343.8010100@suse.cz>
References: <56E2FB5C.1040602@suse.cz>
	<20160314064925.GA27587@js1304-P5Q-DELUXE>
	<56E662E8.700@suse.cz>
	<20160314071803.GA28094@js1304-P5Q-DELUXE>
	<56E92AFC.9050208@huawei.com>
	<20160317065426.GA10315@js1304-P5Q-DELUXE>
	<56EA77BC.2090702@huawei.com>
	<56EAD0B4.2060807@suse.cz>
	<CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
	<56EC0C41.70503@suse.cz>
	<20160323044407.GB4624@js1304-P5Q-DELUXE>
	<56F25343.8010100@suse.cz>
Date: Wed, 23 Mar 2016 17:32:43 +0900
Message-ID: <CAAmzW4Mipu0O6ooqc4Px1oxkpNPh_9RmWkBCj9QrWb+H7+q+xA@mail.gmail.com>
Subject: Re: Suspicious error for CMA stress test
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hanjun Guo <guohanjun@huawei.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lucas Stach <l.stach@pengutronix.de>

2016-03-23 17:26 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 03/23/2016 05:44 AM, Joonsoo Kim wrote:
>>>
>>>
>>> Fixes: 3c605096d315 ("mm/page_alloc: restrict max order of merging on
>>> isolated pageblock")
>>> Link: https://lkml.org/lkml/2016/3/2/280
>>> Reported-by: Hanjun Guo <guohanjun@huawei.com>
>>> Debugged-by: Laura Abbott <labbott@redhat.com>
>>> Debugged-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>>> Cc: <stable@vger.kernel.org> # 3.18+
>>> ---
>>>   mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++-------------
>>>   1 file changed, 33 insertions(+), 13 deletions(-)
>>
>>
>> Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Thanks for taking care of this issue!.
>
>
> Thanks for the review. But I'm now not sure whether we push this to
> mainline+stable now, and later replace with Lucas' approach, or whether that
> approach would be also suitable and non-disruptive enough for stable?

Lucas' approach is for improvement and would be complex rather than
this. I don't think it would be appropriate for stable. IMO, it's better to push
this to mainline + stable now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
