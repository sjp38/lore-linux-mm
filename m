Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 064A76B0036
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 10:41:21 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7636874pab.29
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 07:41:21 -0700 (PDT)
Message-ID: <525C028C.8040900@ti.com>
Date: Mon, 14 Oct 2013 10:41:16 -0400
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [RFC 07/23] mm/memblock: debug: correct displaying of upper memory
 boundary
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com> <1381615146-20342-8-git-send-email-santosh.shilimkar@ti.com> <20131013180227.GD5253@mtj.dyndns.org>
In-Reply-To: <20131013180227.GD5253@mtj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "yinghai@kernel.org" <yinghai@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Strashko, Grygorii" <grygorii.strashko@ti.com>, Andrew Morton <akpm@linux-foundation.org>

On Sunday 13 October 2013 02:02 PM, Tejun Heo wrote:
> On Sat, Oct 12, 2013 at 05:58:50PM -0400, Santosh Shilimkar wrote:
>> From: Grygorii Strashko <grygorii.strashko@ti.com>
>>
>> When debugging is enabled (cmdline has "memblock=debug") the memblock
>> will display upper memory boundary per each allocated/freed memory range
>> wrongly. For example:
>>  memblock_reserve: [0x0000009e7e8000-0x0000009e7ed000] _memblock_early_alloc_try_nid_nopanic+0xfc/0x12c
>>
>> The 0x0000009e7ed000 is displayed instead of 0x0000009e7ecfff
>>
>> Hence, correct this by changing formula used to calculate upper memory
>> boundary to (u64)base + size - 1 instead of  (u64)base + size everywhere
>> in the debug messages.
> 
> I kinda prefer base + size because it's easier to actually know the
> size but yeah, it should have been [base, base + size) and other
> places use base + size - 1 notation so it probably is better to stick
> to that.  Maybe move this one to the beginning of the series?
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> 
Thanks. Will do

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
