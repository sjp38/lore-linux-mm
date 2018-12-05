Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 088C26B7303
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 01:59:22 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so9406115edq.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 22:59:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e44sor10711654ede.13.2018.12.04.22.59.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 22:59:20 -0800 (PST)
Date: Wed, 5 Dec 2018 06:59:18 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] memblock: Anonotate memblock_is_reserved() with
 __init_memblock.
Message-ID: <20181205065918.tvgajb3iag6745s4@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
 <20181204030415.zpcvbzh5gxz5hxc6@master>
 <BLUPR13MB02891C690507E91D0581E79FDFA80@BLUPR13MB0289.namprd13.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR13MB02891C690507E91D0581E79FDFA80@BLUPR13MB0289.namprd13.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yueyi Li <liyueyi@live.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 05, 2018 at 05:37:37AM +0000, Yueyi Li wrote:
>
>On 2018/12/4 11:04, Wei Yang wrote:
>> On Mon, Dec 03, 2018 at 04:00:08AM +0000, Yueyi Li wrote:
>>> Found warning:
>>>
>>> WARNING: EXPORT symbol "gsi_write_channel_scratch" [vmlinux] version generation failed, symbol will not be versioned.
>>> WARNING: vmlinux.o(.text+0x1e0a0): Section mismatch in reference from the function valid_phys_addr_range() to the function .init.text:memblock_is_reserved()
>>> The function valid_phys_addr_range() references
>>> the function __init memblock_is_reserved().
>>> This is often because valid_phys_addr_range lacks a __init
>>> annotation or the annotation of memblock_is_reserved is wrong.
>>>
>>> Use __init_memblock instead of __init.
>> Not familiar with this error, the change looks good to me while have
>> some questions.
>>
>> 1. I don't see valid_phys_addr_range() reference memblock_is_reserved().
>>     This is in which file or arch?
>
>Yes,  I modified valid_phys_addr_range() for some other debugging.
>
>> 2. In case a function reference memblock_is_reserved(), should it has
>>     the annotation of __init_memblock too? Or just __init is ok? If my
>>     understanding is correct, annotation __init is ok. Well, I don't see
>>     valid_phys_addr_range() has an annotation.
>> 3. The only valid_phys_addr_range() reference some memblock function is
>>     the one in arch/arm64/mm/mmap.c. Do we suppose to add an annotation to
>>     this?
>
>Actually, __init_memblock is null in arch arm64, this warning is due to
>CONFIG_DEBUG_SECTION_MISMATCH enabled,  the help text in lib/Kconfig.debug.
>

Ok, thanks.

>
>
>Thanks,
>Yueyi

-- 
Wei Yang
Help you, Help me
