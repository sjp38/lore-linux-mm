Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 662A46B0037
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 13:10:03 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so3572550pbc.27
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:10:03 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id i8si2026031pav.74.2014.01.24.10.10.00
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 10:10:01 -0800 (PST)
Message-ID: <52E2AC5A.3000005@intel.com>
Date: Fri, 24 Jan 2014 10:09:30 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
References: <52E19C7D.7050603@intel.com>	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>	<52E28067.1060507@intel.com> <CAE9FiQVy+8CF5qwnyL8YGzqwKOJF+y7N_+reAXWw7p8-BaVQPg@mail.gmail.com>
In-Reply-To: <CAE9FiQVy+8CF5qwnyL8YGzqwKOJF+y7N_+reAXWw7p8-BaVQPg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 01/24/2014 09:45 AM, Yinghai Lu wrote:
> On Fri, Jan 24, 2014 at 7:01 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>> There are two failure modes I'm seeing: one when (failing to) allocate
>> the first node's mem_map[], and a second where it oopses accessing the
>> numa_distance[] table.  This is the numa_distance[] one, and it happens
>> even with the patch you suggested applied.
>>
>>> [    0.000000] memblock_find_in_range_node():239
>>> [    0.000000] __memblock_find_range_top_down():150
>>> [    0.000000] __memblock_find_range_top_down():152 i: 600000001
>>> [    0.000000] memblock_find_in_range_node():241 ret: 2147479552
>>> [    0.000000] memblock_reserve: [0x0000007ffff000-0x0000007ffff03f] flags 0x0 numa_set_distance+0xd2/0x252
> 
> that address is wrong.
> 
> Can you post whole log with current linus' tree + two patches that I
> sent out yesterday?

Here you go.  It's still spitting out memblock_reserve messages to the
console.  I'm not sure if it's making _some_ progress or not.

	https://www.sr71.net/~dave/intel/3.13/dmesg.with-2-patches

But, it's certainly not booting.  Do you want to see it without
memblock=debug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
