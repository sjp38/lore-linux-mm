Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 573A96B0098
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 04:26:38 -0400 (EDT)
Date: Mon, 31 Aug 2009 10:26:32 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86: reuse the boot-time mappings of fixed_addresses
Message-ID: <20090831082632.GB15619@elte.hu>
References: <4A90AADE.20307@gmail.com> <20090829110046.GA6812@elte.hu> <4A997088.60908@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A997088.60908@zytor.com>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Xiao Guangrong <ericxiao.gr@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jens Axboe <jens.axboe@oracle.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org, Jeremy Fitzhardinge <jeremy@goop.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>


* H. Peter Anvin <hpa@zytor.com> wrote:

> Ingo Molnar wrote:
>> * Xiao Guangrong <ericxiao.gr@gmail.com> wrote:
>>
>>> From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
>>>
>>> Some fixed_addresses items are only used when system boot, after  
>>> boot, they are free but no way to use, like early ioremap area. They 
>>> are wasted for us, we can reuse them after system boot.
>>>
>>> In this patch, we put them in permanent kmap's area and expand  
>>> vmalloc's address range. In boot time, reserve them in  
>>> permanent_kmaps_init() to avoid multiple used, after system boot, we 
>>> unreserved them then user can use it.
>>>
>>> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
>>> ---
>>>  arch/x86/include/asm/fixmap.h           |    2 ++
>>>  arch/x86/include/asm/pgtable_32_types.h |    4 ++--
>>>  arch/x86/mm/init_32.c                   |    8 ++++++++
>>>  include/linux/highmem.h                 |    2 ++
>>>  mm/highmem.c                            |   26 ++++++++++++++++++++++++++
>>>  5 files changed, 40 insertions(+), 2 deletions(-)
>>
>> I'm wondering, how much space do we save this way, on a typical bootup 
>> on a typical PC?
>>
>
> Not a huge lot... a few dozen pages.

I guess it's still worth doing - what do you think?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
