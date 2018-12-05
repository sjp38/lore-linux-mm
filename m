Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEDD76B72BB
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:37:39 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id n196so11822504oig.15
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:37:39 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-oln040092001051.outbound.protection.outlook.com. [40.92.1.51])
        by mx.google.com with ESMTPS id k18si8691865otj.208.2018.12.04.21.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Dec 2018 21:37:39 -0800 (PST)
From: Yueyi Li <liyueyi@live.com>
Subject: Re: [PATCH v2] memblock: Anonotate memblock_is_reserved() with
 __init_memblock.
Date: Wed, 5 Dec 2018 05:37:37 +0000
Message-ID: <BLUPR13MB02891C690507E91D0581E79FDFA80@BLUPR13MB0289.namprd13.prod.outlook.com>
References: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
 <20181204030415.zpcvbzh5gxz5hxc6@master>
In-Reply-To: <20181204030415.zpcvbzh5gxz5hxc6@master>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-ID: <3F6DD7343CFD8C43BA08FE6D04863379@namprd13.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


On 2018/12/4 11:04, Wei Yang wrote:
> On Mon, Dec 03, 2018 at 04:00:08AM +0000, Yueyi Li wrote:
>> Found warning:
>>
>> WARNING: EXPORT symbol "gsi_write_channel_scratch" [vmlinux] version gen=
eration failed, symbol will not be versioned.
>> WARNING: vmlinux.o(.text+0x1e0a0): Section mismatch in reference from th=
e function valid_phys_addr_range() to the function .init.text:memblock_is_r=
eserved()
>> The function valid_phys_addr_range() references
>> the function __init memblock_is_reserved().
>> This is often because valid_phys_addr_range lacks a __init
>> annotation or the annotation of memblock_is_reserved is wrong.
>>
>> Use __init_memblock instead of __init.
> Not familiar with this error, the change looks good to me while have
> some questions.
>
> 1. I don't see valid_phys_addr_range() reference memblock_is_reserved().
>     This is in which file or arch?

Yes,  I modified valid_phys_addr_range() for some other debugging.

> 2. In case a function reference memblock_is_reserved(), should it has
>     the annotation of __init_memblock too? Or just __init is ok? If my
>     understanding is correct, annotation __init is ok. Well, I don't see
>     valid_phys_addr_range() has an annotation.
> 3. The only valid_phys_addr_range() reference some memblock function is
>     the one in arch/arm64/mm/mmap.c. Do we suppose to add an annotation t=
o
>     this?

Actually, __init_memblock is null in arch arm64, this warning is due to
CONFIG_DEBUG_SECTION_MISMATCH enabled,  the help text in lib/Kconfig.debug.



Thanks,
Yueyi
