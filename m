Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id BC6926B0254
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 04:44:43 -0500 (EST)
Received: by oihr132 with SMTP id r132so565867oih.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 01:44:43 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id v81si16875086oia.92.2015.12.11.01.44.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Dec 2015 01:44:43 -0800 (PST)
Message-ID: <566A9AE1.7020001@huawei.com>
Date: Fri, 11 Dec 2015 17:44:01 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com> <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com> <56679FDC.1080800@huawei.com> <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com> <5668D1FA.4050108@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01> <56691819.3040105@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen,
 Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/12/11 13:53, Izumi, Taku wrote:

> Dear Xishi,
> 
>> Hi Taku,
>>
>> Whether it is possible that we rewrite the fallback function in buddy system
>> when zone_movable and mirrored_kernelcore are both enabled?
> 
>   What does "when zone_movable and mirrored_kernelcore are both enabled?" mean ?
>   
>   My patchset just provides a new way to create ZONE_MOVABLE.
> 

Hi Taku,

I mean when zone_movable is from kernelcore=mirror, not kernelcore=nn[KMG].

Thanks,
Xishi Qiu

>   Sincerely,
>   Taku Izumi
>>
>> It seems something like that we add a new zone but the name is zone_movable,
>> not zone_mirror. And the prerequisite is that we won't enable these two
>> features(movable memory and mirrored memory) at the same time. Thus we can
>> reuse the code of movable zone.
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
