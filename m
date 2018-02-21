Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4C36B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 10:02:28 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y44so1615905wry.8
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 07:02:28 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id b81si205073wmd.97.2018.02.21.07.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 07:02:26 -0800 (PST)
Subject: Re: [PATCH 0/6] DISCONTIGMEM support for PPC32
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
 <193a407d-e6b8-9e29-af47-3d401b6414a0@c-s.fr>
 <20180221144240.pfu2run3pixt3pzo@latitude>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <a36983ec-5e97-e968-8143-1b2615ea55f8@c-s.fr>
Date: Wed, 21 Feb 2018 16:02:25 +0100
MIME-Version: 1.0
In-Reply-To: <20180221144240.pfu2run3pixt3pzo@latitude>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>
Cc: linuxppc-dev@lists.ozlabs.org, Joel Stanley <joel@jms.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



Le 21/02/2018 A  15:42, Jonathan NeuschA?fer a A(C)critA :
> Hi,
> 
> On Wed, Feb 21, 2018 at 08:06:10AM +0100, Christophe LEROY wrote:
>>
>>
>> Le 20/02/2018 A  17:14, Jonathan NeuschA?fer a A(C)critA :
>>> This patchset adds support for DISCONTIGMEM on 32-bit PowerPC. This is
>>> required to properly support the Nintendo Wii's memory layout, in which
>>> there are two blocks of RAM and MMIO in the middle.
>>>
>>> Previously, this memory layout was handled by code that joins the two
>>> RAM blocks into one, reserves the MMIO hole, and permits allocations of
>>> reserved memory in ioremap. This hack didn't work with resource-based
>>> allocation (as used for example in the GPIO driver for Wii[1]), however.
>>>
>>> After this patchset, users of the Wii can either select CONFIG_FLATMEM
>>> to get the old behaviour, or CONFIG_DISCONTIGMEM to get the new
>>> behaviour.
>>
>> My question might me stupid, as I don't know PCC64 in deep, but when looking
>> at page_is_ram() in arch/powerpc/mm/mem.c, I have the feeling the PPC64
>> implements ram by blocks. Isn't it what you are trying to achieve ? Wouldn't
>> it be feasible to map to what's done in PPC64 for PPC32 ?
> 
> Using page_is_ram in __ioremap_caller and the same memblock-based
> approach that's used on PPC64 on PPC32 *should* work, but I think due to
> the following line in initmem_init, it won't:
> 
> 	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);

Can't we just fix that ?

Christophe

> 
> 
> Thanks,
> Jonathan NeuschA?fer
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
