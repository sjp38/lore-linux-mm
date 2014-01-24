Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 78FB96B0037
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 12:45:20 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id v15so1313061bkz.22
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:45:19 -0800 (PST)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id om1si3842351bkb.219.2014.01.24.09.45.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 09:45:19 -0800 (PST)
Received: by mail-ie0-f174.google.com with SMTP id tp5so3204490ieb.19
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:45:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E28067.1060507@intel.com>
References: <52E19C7D.7050603@intel.com>
	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>
	<52E28067.1060507@intel.com>
Date: Fri, 24 Jan 2014 09:45:17 -0800
Message-ID: <CAE9FiQVy+8CF5qwnyL8YGzqwKOJF+y7N_+reAXWw7p8-BaVQPg@mail.gmail.com>
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 24, 2014 at 7:01 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> There are two failure modes I'm seeing: one when (failing to) allocate
> the first node's mem_map[], and a second where it oopses accessing the
> numa_distance[] table.  This is the numa_distance[] one, and it happens
> even with the patch you suggested applied.
>
>> [    0.000000] memblock_find_in_range_node():239
>> [    0.000000] __memblock_find_range_top_down():150
>> [    0.000000] __memblock_find_range_top_down():152 i: 600000001
>> [    0.000000] memblock_find_in_range_node():241 ret: 2147479552
>> [    0.000000] memblock_reserve: [0x0000007ffff000-0x0000007ffff03f] flags 0x0 numa_set_distance+0xd2/0x252

that address is wrong.

Can you post whole log with current linus' tree + two patches that I
sent out yesterday?

>> [    0.000000] numa_distance phys: 7ffff000
>> [    0.000000] numa_distance virt: ffff88007ffff000
>> [    0.000000] numa_distance size: 64
>> [    0.000000] numa_alloc_distance() accessing numa_distance[] at byte: 0
>> [    0.000000] BUG: unable to handle kernel paging request at ffff88007ffff000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
