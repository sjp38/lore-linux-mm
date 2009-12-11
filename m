Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6001F6B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:08:44 -0500 (EST)
Received: by pwi1 with SMTP id 1so738966pwi.6
        for <linux-mm@kvack.org>; Fri, 11 Dec 2009 06:08:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B224E7A.2060708@redhat.com>
References: <20091210185626.26f9828a@cuia.bos.redhat.com>
	 <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
	 <4B2235F0.4080606@redhat.com>
	 <28c262360912110541m2839e151hc9d49b0c251e1b67@mail.gmail.com>
	 <4B224E7A.2060708@redhat.com>
Date: Fri, 11 Dec 2009 23:08:42 +0900
Message-ID: <28c262360912110608y13c76af0g4acff99d39173493@mail.gmail.com>
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, Dec 11, 2009 at 10:51 PM, Rik van Riel <riel@redhat.com> wrote:
> On 12/11/2009 08:41 AM, Minchan Kim wrote:
>>
>> Hi, Larry.
>>
>> On Fri, Dec 11, 2009 at 9:07 PM, Larry Woodman<lwoodman@redhat.com>
>> =C2=A0wrote:
>>>
>>> Minchan Kim wrote:
>>>>
>>>> I like this. but why do you select default value as constant 8?
>>>> Do you have any reason?
>>>>
>>>> I think it would be better to select the number proportional to NR_CPU=
.
>>>> ex) NR_CPU * 2 or something.
>>>>
>>>> Otherwise looks good to me.
>>>>
>>>> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>
>>>>
>>>>
>>>
>>> This is a per-zone count so perhaps a reasonable default is the number =
of
>>> CPUs on the
>>> NUMA node that the zone resides on ?
>>
>> For example, It assume one CPU per node.
>> It means your default value is 1.
>> On the CPU, process A try to reclaim HIGH zone.
>> Process B want to reclaim NORMAL zone.
>> But Process B can't enter reclaim path sincev throttle default value is =
1
>> Even kswap can't reclaim.
>
> 1) the value is per zone, so process B can go ahead

Sorry. I misunderstood Larry's point.
I though Larry mentioned global limit not per zone.

> 2) kswapd is always excempt from this limit, since
> =C2=A0 there is only 1 kswapd per node anyway

Larry could test with Rik's patch for what's good default value.
If it proves NR_CPU on node is proper as default value,
We can change default value with it.


> --
> All rights reversed.
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
