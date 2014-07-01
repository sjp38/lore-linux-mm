Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4C61B6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 14:45:18 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so8583329iec.9
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 11:45:18 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id d18si35710127ics.56.2014.07.01.11.45.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 11:45:17 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id h18so5822682igc.10
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 11:45:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53B26364.1040606@huawei.com>
References: <53B26229.5030504@huawei.com>
	<53B26364.1040606@huawei.com>
Date: Tue, 1 Jul 2014 11:45:16 -0700
Message-ID: <CAE9FiQWpPOELEAOZxxZafpkYqYPurL_Fx_zJsS4XM+DmFCYbxg@mail.gmail.com>
Subject: Re: How to boot up an ARM board enabled CONFIG_SPARSEMEM
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, wangnan0@huawei.com

On Tue, Jul 1, 2014 at 12:29 AM, Zhang Zhen <zhenzhang.zhang@huawei.com> wrote:
> Hi,
>
> Recently We are testing stable kernel 3.10 on an ARM board.
> It failed to boot if we enabled CONFIG_SPARSEMEM config.

Arm support 2 sockets and numa now?

> 1. In mem_init() and show_mem() compare pfn instead of page just like the patch in attachement.
> 2. Enable CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER when enabled CONFIG_SPARSEMEM.
>
> QUESTION:
>
> I want to know why CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER depends on x86_64 ?

That make memory allocation have less memory hole, from old bootmem bitmap
allocation stage.

Maybe we don't need that anymore as we have memblock allocation that is more
smarter with alignment handling.

Also allocating big size and use them block by block, could save some time on
searching on allocation function when memblock have lots of entries on
memory/reserved arrays.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
