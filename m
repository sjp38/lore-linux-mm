Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBD32802EB
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 01:29:56 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so37979003pdj.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 22:29:55 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id f10si11060295pdp.225.2015.07.15.22.29.54
        for <linux-mm@kvack.org>;
        Wed, 15 Jul 2015 22:29:55 -0700 (PDT)
Message-ID: <55A7417C.6000106@cn.fujitsu.com>
Date: Thu, 16 Jul 2015 13:30:36 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mem-hotplug: Handle node hole when initializing numa_meminfo.
References: <1435720614-16480-1-git-send-email-tangchen@cn.fujitsu.com> <20150715212008.GK15934@mtj.duckdns.org>
In-Reply-To: <20150715212008.GK15934@mtj.duckdns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, dyoung@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, lcapitulino@redhat.com, qiuxishi@huawei.com, will.deacon@arm.com, tony.luck@intel.com, vladimir.murzin@arm.com, fabf@skynet.be, kuleshovmail@gmail.com, bhe@redhat.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On 07/16/2015 05:20 AM, Tejun Heo wrote:
> On Wed, Jul 01, 2015 at 11:16:54AM +0800, Tang Chen wrote:
> ...
>> -		/* and there's no empty block */
>> -		if (bi->start >= bi->end)
>> +		/* and there's no empty or non-exist block */
>> +		if (bi->start >= bi->end ||
>> +		    memblock_overlaps_region(&memblock.memory,
>> +			bi->start, bi->end - bi->start) == -1)
> Ugh.... can you please change memblock_overlaps_region() to return
> bool instead?

Well, I think memblock_overlaps_region() is designed to return
the index of the region overlapping with the given region.
Maybe it had some users before.

Of course for now, it is only called by memblock_is_region_reserved().

It is OK to change the return value of memblock_overlaps_region() to bool.
But any caller of memblock_is_region_reserved() should also be changed.

I think it is OK to leave it there.

Thanks.

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
