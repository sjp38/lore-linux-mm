Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 61AAF6B0038
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 21:42:41 -0400 (EDT)
Received: by oiao187 with SMTP id o187so1741611oia.3
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 18:42:41 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q65si298711oif.110.2015.10.19.18.42.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 Oct 2015 18:42:40 -0700 (PDT)
Message-ID: <56259BFF.1090203@huawei.com>
Date: Tue, 20 Oct 2015 09:42:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Introduce kernelcore=reliable option
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com> <5624548F.30500@huawei.com> <E86EADE93E2D054CBCD4E708C38D364A5427FECE@G01JPEXMBYT01>
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A5427FECE@G01JPEXMBYT01>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/10/20 8:34, Izumi, Taku wrote:

>  Hi Xishi,
> 
>> On 2015/10/15 21:32, Taku Izumi wrote:
>>
>>> Xeon E7 v3 based systems supports Address Range Mirroring
>>> and UEFI BIOS complied with UEFI spec 2.5 can notify which
>>> ranges are reliable (mirrored) via EFI memory map.
>>> Now Linux kernel utilize its information and allocates
>>> boot time memory from reliable region.
>>>
>>> My requirement is:
>>>   - allocate kernel memory from reliable region
>>>   - allocate user memory from non-reliable region
>>>
>>> In order to meet my requirement, ZONE_MOVABLE is useful.
>>> By arranging non-reliable range into ZONE_MOVABLE,
>>> reliable memory is only used for kernel allocations.
>>>
>>> This patch extends existing "kernelcore" option and
>>> introduces kernelcore=reliable option. By specifying
>>> "reliable" instead of specifying the amount of memory,
>>> non-reliable region will be arranged into ZONE_MOVABLE.
>>>
>>> Earlier discussion is at:
>>>  https://lkml.org/lkml/2015/10/9/24
>>>
>>
>> Hi Taku,
>>
>> If user don't want to waste a lot of memory, and he only set
>> a few memory to mirrored memory, then the kernelcore is very
>> small, right? That means OS will have a very small normal zone
>> and a very large movable zone.
> 
>  Right.
> 
>> Kernel allocation could only use the unmovable zone. As the
>> normal zone is very small, the kernel allocation maybe OOM,
>> right?
> 
>  Right.
> 
>> Do you mean that we will reuse the movable zone in short-term
>> solution and create a new zone(mirrored zone) in future?
> 
>  If there is that kind of requirements, I don't oppose 
>  creating a new zone.
> 

As far as I know, some apps(e.g. date base) maybe could only use
the normal zone.

Thanks,
Xishi Qiu

>  Sincerely,
>  Taku Izumi
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
