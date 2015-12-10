Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4A67882F7A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 01:17:39 -0500 (EST)
Received: by pabur14 with SMTP id ur14so42420412pab.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 22:17:39 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id r79si18085738pfi.230.2015.12.09.22.17.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 22:17:38 -0800 (PST)
Message-ID: <56691819.3040105@huawei.com>
Date: Thu, 10 Dec 2015 14:13:45 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com> <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com> <56679FDC.1080800@huawei.com> <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com> <5668D1FA.4050108@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen,
 Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/12/10 13:37, Izumi, Taku wrote:

> Dear Tony, Xishi,
> 
>>>> How about add some comment, if mirrored memroy is too small, then the
>>>> normal zone is small, so it may be oom.
>>>> The mirrored memory is at least 1/64 of whole memory, because struct
>>>> pages usually take 64 bytes per page.
>>>
>>> 1/64th is the absolute lower bound (for the page structures as you say). I
>>> expect people will need to configure 10% or more to run any real workloads.
> 
>>>
>>> I made the memblock boot time allocator fall back to non-mirrored memory
>>> if mirrored memory ran out.  What happens in the run time allocator if the
>>> non-movable zones run out of pages? Will we allocate kernel pages from movable
>>> memory?
>>>
>>
>> As I know, the kernel pages will not allocated from movable zone.
> 
>  Yes, kernel pages are not allocated from ZONE_MOVABLE.
> 
>  In this case administrator must review and reconfigure the mirror ratio via 
>  "MirrorRequest" EFI variable.
>  
>   Sincerely,
>   Taku Izumi
> 

Hi Taku,

Whether it is possible that we rewrite the fallback function in buddy system
when zone_movable and mirrored_kernelcore are both enabled?

It seems something like that we add a new zone but the name is zone_movable,
not zone_mirror. And the prerequisite is that we won't enable these two
features(movable memory and mirrored memory) at the same time. Thus we can
reuse the code of movable zone.

Thanks,
Xishi Qiu

>>
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
