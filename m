Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B6C006B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 00:56:25 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so14202327pab.20
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 21:56:25 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id rs10si606660pbc.75.2014.08.12.21.56.23
        for <linux-mm@kvack.org>;
        Tue, 12 Aug 2014 21:56:24 -0700 (PDT)
Message-ID: <53EAF01C.3090404@cn.fujitsu.com>
Date: Wed, 13 Aug 2014 12:57:00 +0800
From: tangchen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] memblock, memhotplug: Fix wrong type in memblock_find_in_range_node().
References: <1407651123-10994-1-git-send-email-tangchen@cn.fujitsu.com> <20140812150304.74a7da3f2491f3d8f8a30107@linux-foundation.org>
In-Reply-To: <20140812150304.74a7da3f2491f3d8f8a30107@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: santosh.shilimkar@ti.com, grygorii.strashko@ti.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, fabf@skynet.be, Emilian.Medve@freescale.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 08/13/2014 06:03 AM, Andrew Morton wrote:
> On Sun, 10 Aug 2014 14:12:03 +0800 Tang Chen <tangchen@cn.fujitsu.com> wrote:
>
>> In memblock_find_in_range_node(), we defeind ret as int. But it shoule
>> be phys_addr_t because it is used to store the return value from
>> __memblock_find_range_bottom_up().
>>
>> The bug has not been triggered because when allocating low memory near
>> the kernel end, the "int ret" won't turn out to be minus. When we started
>> to allocate memory on other nodes, and the "int ret" could be minus.
>> Then the kernel will panic.
>>
>> A simple way to reproduce this: comment out the following code in numa_init(),
>>
>>          memblock_set_bottom_up(false);
>>
>> and the kernel won't boot.
> Which kernel versions need this fix?

This bug has been in the kernel since v3.13-rc1.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
