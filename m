Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A67C06B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:48:20 -0500 (EST)
Message-ID: <4B224D9C.6070804@redhat.com>
Date: Fri, 11 Dec 2009 08:48:12 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091210185626.26f9828a@cuia.bos.redhat.com> <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com> <4B2235F0.4080606@redhat.com>
In-Reply-To: <4B2235F0.4080606@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: Minchan Kim <minchan.kim@gmail.com>, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 12/11/2009 07:07 AM, Larry Woodman wrote:
> Minchan Kim wrote:
>>
>> I like this. but why do you select default value as constant 8?
>> Do you have any reason?
>>
>> I think it would be better to select the number proportional to NR_CPU.
>> ex) NR_CPU * 2 or something.
>>
>> Otherwise looks good to me.
>>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>>
> This is a per-zone count so perhaps a reasonable default is the number
> of CPUs on the
> NUMA node that the zone resides on ?

One reason I made it tunable is so people can easily test
what a good value would be :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
