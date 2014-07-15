Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 84F296B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 19:46:58 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so176115pad.9
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:46:58 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id cc2si12891864pbc.255.2014.07.15.16.46.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 16:46:57 -0700 (PDT)
Message-ID: <53C5BD3E.2010600@zytor.com>
Date: Tue, 15 Jul 2014 16:46:06 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to handle
 WT type
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com> <1405452884-25688-4-git-send-email-toshi.kani@hp.com> <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com> <1405465801.28702.34.camel@misato.fc.hp.com> <CALCETrUx+HkzBmTZo-BtOcOz7rs=oNcavJ9Go536Fcn2ugdobg@mail.gmail.com>
In-Reply-To: <CALCETrUx+HkzBmTZo-BtOcOz7rs=oNcavJ9Go536Fcn2ugdobg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Toshi Kani <toshi.kani@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On 07/15/2014 04:36 PM, Andy Lutomirski wrote:
> On Tue, Jul 15, 2014 at 4:10 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>> On Tue, 2014-07-15 at 12:56 -0700, Andy Lutomirski wrote:
>>> On Tue, Jul 15, 2014 at 12:34 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>>>> This patch changes reserve_memtype() to handle the new WT type.
>>>> When (!pat_enabled && new_type), it continues to set either WB
>>>> or UC- to *new_type.  When pat_enabled, it can reserve a given
>>>> non-RAM range for WT.  At this point, it may not reserve a RAM
>>>> range for WT since reserve_ram_pages_type() uses the page flags
>>>> limited to three memory types, WB, WC and UC.
>>>
>>> FWIW, last time I looked at this, it seemed like all the fancy
>>> reserve_ram_pages stuff was unnecessary: shouldn't the RAM type be
>>> easy to track in the direct map page tables?
>>
>> Are you referring the direct map page tables as the kernel page
>> directory tables (pgd/pud/..)?
>>
>> I think it needs to be able to keep track of the memory type per a
>> physical memory range, not per a translation, in order to prevent
>> aliasing of the memory type.
> 
> Actual RAM (the lowmem kind, which is all of it on x86_64) is mapped
> linearly somewhere in kernel address space.  The pagetables for that
> mapping could be used as the canonical source of the memory type for
> the ram range in question.
> 
> This only works for lowmem, so maybe it's not a good idea to rely on it.
> 

We could do that, but would it be better?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
