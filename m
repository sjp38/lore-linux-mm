Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 18E9A6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 23:51:55 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id iw8so48936761obc.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 20:51:55 -0800 (PST)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id d200si8748841oib.7.2015.12.16.20.51.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Dec 2015 20:51:54 -0800 (PST)
Message-ID: <56723E8B.8050201@huawei.com>
Date: Thu, 17 Dec 2015 12:48:11 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com> <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com> <56679FDC.1080800@huawei.com> <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com> <5668D1FA.4050108@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01> <56691819.3040105@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01> <566A9AE1.7020001@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01> <56722258.6030800@huawei.com> <567223A7.9090407@jp.fujitsu.com>
In-Reply-To: <567223A7.9090407@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/12/17 10:53, Kamezawa Hiroyuki wrote:

> On 2015/12/17 11:47, Xishi Qiu wrote:
>> On 2015/12/17 9:38, Izumi, Taku wrote:
>>
>>> Dear Xishi,
>>>
>>>   Sorry for late.
>>>
>>>> -----Original Message-----
>>>> From: Xishi Qiu [mailto:qiuxishi@huawei.com]
>>>> Sent: Friday, December 11, 2015 6:44 PM
>>>> To: Izumi, Taku/泉 拓
>>>> Cc: Luck, Tony; linux-kernel@vger.kernel.org; linux-mm@kvack.org; akpm@linux-foundation.org; Kamezawa, Hiroyuki/亀澤 寛
>>>> 之; mel@csn.ul.ie; Hansen, Dave; matt@codeblueprint.co.uk
>>>> Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
>>>>
>>>> On 2015/12/11 13:53, Izumi, Taku wrote:
>>>>
>>>>> Dear Xishi,
>>>>>
>>>>>> Hi Taku,
>>>>>>
>>>>>> Whether it is possible that we rewrite the fallback function in buddy system
>>>>>> when zone_movable and mirrored_kernelcore are both enabled?
>>>>>
>>>>>    What does "when zone_movable and mirrored_kernelcore are both enabled?" mean ?
>>>>>
>>>>>    My patchset just provides a new way to create ZONE_MOVABLE.
>>>>>
>>>>
>>>> Hi Taku,
>>>>
>>
>> Hi Taku,
>>
>> We can NOT specify kernelcore= "nn[KMG]" and "mirror" at the same time.
>> So when we use "mirror", in fact, the movable zone is a new zone. I think it is
>> more appropriate with this name "mirrored zone", and also we can rewrite the
>> fallback function in buddy system in this case.
> 
> kernelcore ="mirrored zone" ?

No, it's zone_names[MAX_NR_ZONES]
How about "Movable", -> "Non-mirrored"?

> 
> BTW, let me confirm.
> 
>   ZONE_NORMAL = mirrored
>   ZONE_MOVABLE = not mirrored.
> 

Yes, 

> so, the new zone is "not-mirrored" zone.
> 
> Now, fallback function is
> 
>    movable -> normal -> DMA.
> 
> As Tony requested, we may need a knob to stop a fallback in "movable->normal", later.
> 

If the mirrored memory is small and the other is large,
I think we can both enable "non-mirrored -> normal" and "normal -> non-mirrored".

Thanks,
Xishi Qiu

> Thanks,
> -Kame
> 
> 
> 
> 
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
