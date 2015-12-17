Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id E5D0E6B0255
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 21:56:47 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id q126so41207747iof.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 18:56:47 -0800 (PST)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id jg6si366342igb.70.2015.12.16.18.56.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Dec 2015 18:56:46 -0800 (PST)
Message-ID: <56722258.6030800@huawei.com>
Date: Thu, 17 Dec 2015 10:47:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com> <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com> <56679FDC.1080800@huawei.com> <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com> <5668D1FA.4050108@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01> <56691819.3040105@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01> <566A9AE1.7020001@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01>
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen,
 Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/12/17 9:38, Izumi, Taku wrote:

> Dear Xishi,
> 
>  Sorry for late.
> 
>> -----Original Message-----
>> From: Xishi Qiu [mailto:qiuxishi@huawei.com]
>> Sent: Friday, December 11, 2015 6:44 PM
>> To: Izumi, Taku/泉 拓
>> Cc: Luck, Tony; linux-kernel@vger.kernel.org; linux-mm@kvack.org; akpm@linux-foundation.org; Kamezawa, Hiroyuki/亀澤 寛
>> 之; mel@csn.ul.ie; Hansen, Dave; matt@codeblueprint.co.uk
>> Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
>>
>> On 2015/12/11 13:53, Izumi, Taku wrote:
>>
>>> Dear Xishi,
>>>
>>>> Hi Taku,
>>>>
>>>> Whether it is possible that we rewrite the fallback function in buddy system
>>>> when zone_movable and mirrored_kernelcore are both enabled?
>>>
>>>   What does "when zone_movable and mirrored_kernelcore are both enabled?" mean ?
>>>
>>>   My patchset just provides a new way to create ZONE_MOVABLE.
>>>
>>
>> Hi Taku,
>>

Hi Taku,

We can NOT specify kernelcore= "nn[KMG]" and "mirror" at the same time.
So when we use "mirror", in fact, the movable zone is a new zone. I think it is
more appropriate with this name "mirrored zone", and also we can rewrite the
fallback function in buddy system in this case.

Thanks,
Xishi Qiu

>> I mean when zone_movable is from kernelcore=mirror, not kernelcore=nn[KMG].
> 
>   I'm not quite sure what you are saying, but if you want to screen user memory
>   so that one is allocated from mirrored zone and another is from non-mirrored zone,
>   I think it is possible to reuse my patchset.
> 
>   Sincerely,
>   Taku Izumi
> 
>> Thanks,
>> Xishi Qiu
>>
>>>   Sincerely,
>>>   Taku Izumi
>>>>
>>>> It seems something like that we add a new zone but the name is zone_movable,
>>>> not zone_mirror. And the prerequisite is that we won't enable these two
>>>> features(movable memory and mirrored memory) at the same time. Thus we can
>>>> reuse the code of movable zone.
>>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>
>>> .
>>>
>>
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
