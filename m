Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id C86596B0255
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 21:53:59 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id e126so41249108ioa.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 18:53:59 -0800 (PST)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id m132si4205026ioa.163.2015.12.16.18.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 18:53:58 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 59BDBAC02BC
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:53:49 +0900 (JST)
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
 <5668D1FA.4050108@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
 <56691819.3040105@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
 <566A9AE1.7020001@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01>
 <56722258.6030800@huawei.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <567223A7.9090407@jp.fujitsu.com>
Date: Thu, 17 Dec 2015 11:53:27 +0900
MIME-Version: 1.0
In-Reply-To: <56722258.6030800@huawei.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/12/17 11:47, Xishi Qiu wrote:
> On 2015/12/17 9:38, Izumi, Taku wrote:
> 
>> Dear Xishi,
>>
>>   Sorry for late.
>>
>>> -----Original Message-----
>>> From: Xishi Qiu [mailto:qiuxishi@huawei.com]
>>> Sent: Friday, December 11, 2015 6:44 PM
>>> To: Izumi, Taku/泉 拓
>>> Cc: Luck, Tony; linux-kernel@vger.kernel.org; linux-mm@kvack.org; akpm@linux-foundation.org; Kamezawa, Hiroyuki/亀澤 寛
>>> 之; mel@csn.ul.ie; Hansen, Dave; matt@codeblueprint.co.uk
>>> Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
>>>
>>> On 2015/12/11 13:53, Izumi, Taku wrote:
>>>
>>>> Dear Xishi,
>>>>
>>>>> Hi Taku,
>>>>>
>>>>> Whether it is possible that we rewrite the fallback function in buddy system
>>>>> when zone_movable and mirrored_kernelcore are both enabled?
>>>>
>>>>    What does "when zone_movable and mirrored_kernelcore are both enabled?" mean ?
>>>>
>>>>    My patchset just provides a new way to create ZONE_MOVABLE.
>>>>
>>>
>>> Hi Taku,
>>>
> 
> Hi Taku,
> 
> We can NOT specify kernelcore= "nn[KMG]" and "mirror" at the same time.
> So when we use "mirror", in fact, the movable zone is a new zone. I think it is
> more appropriate with this name "mirrored zone", and also we can rewrite the
> fallback function in buddy system in this case.

kernelcore ="mirrored zone" ?

BTW, let me confirm.

  ZONE_NORMAL = mirrored
  ZONE_MOVABLE = not mirrored.

so, the new zone is "not-mirrored" zone.

Now, fallback function is

   movable -> normal -> DMA.

As Tony requested, we may need a knob to stop a fallback in "movable->normal", later.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
