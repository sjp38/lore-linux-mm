Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DBA3B2802E6
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 03:21:06 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so38404811pac.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 00:21:06 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id e5si11535484pdf.100.2015.07.16.00.21.05
        for <linux-mm@kvack.org>;
        Thu, 16 Jul 2015 00:21:06 -0700 (PDT)
Message-ID: <55A75B8D.5010009@cn.fujitsu.com>
Date: Thu, 16 Jul 2015 15:21:49 +0800
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

Of course for now, it is only called by memblock_is_region_reserved().

Will post a patch to do this.

Thanks.

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
