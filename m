Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id C5EB16B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 11:03:35 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so7447748pbb.27
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 08:03:35 -0700 (PDT)
Message-ID: <525C07C0.2020303@ti.com>
Date: Mon, 14 Oct 2013 11:03:28 -0400
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [RFC 06/23] mm/memblock: Add memblock early memory allocation
 apis
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com> <1381615146-20342-7-git-send-email-santosh.shilimkar@ti.com> <20131013175648.GC5253@mtj.dyndns.org> <525C023A.8070608@ti.com> <20131014145833.GK4722@htj.dyndns.org>
In-Reply-To: <20131014145833.GK4722@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "yinghai@kernel.org" <yinghai@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Strashko, Grygorii" <grygorii.strashko@ti.com>, Andrew Morton <akpm@linux-foundation.org>

On Monday 14 October 2013 10:58 AM, Tejun Heo wrote:
> Hello,
> 
> On Mon, Oct 14, 2013 at 10:39:54AM -0400, Santosh Shilimkar wrote:
>>>> +void __memblock_free_early(phys_addr_t base, phys_addr_t size);
>>>> +void __memblock_free_late(phys_addr_t base, phys_addr_t size);
>>>
>>> Would it be possible to drop "early"?  It's redundant and makes the
>>> function names unnecessarily long.  When memblock is enabled, these
>>> are basically doing about the same thing as memblock_alloc() and
>>> friends, right?  Wouldn't it make more sense to define these as
>>> memblock_alloc_XXX()?
>>>
>> A small a difference w.r.t existing memblock_alloc() vs these new
>> exports returns virtual mapped memory pointers. Actually I started
>> with memblock_alloc_xxx() but then memblock already exports memblock_alloc_xx()
>> returning physical memory pointer. So just wanted to make these interfaces
>> distinct and added "early". But I agree with you that the 'early' can
>> be dropped. Will fix it.
> 
> Hmmm, so while this removes address limit on the base / limit side, it
> keeps virt address on the result.  In that case, we probably want to
> somehow distinguish the two sets of interfaces - one set dealing with
> phys and the other dealing with virts.  Maybe we want to build the
> base interface on phys address and add convenience wrappers for virts?
> Would that make more sense?
> 
Thats what more or less we are doing if you look at it. The only
additional code we have is to manage the virtual memory and checks
as such, just the same way initially done in nobootmem.c wrappers.

Not sure if adding 'virt' word in these APIs to make it explicit
would help to avoid any confusion.

Regards,
Santosh



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
