Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id C241A828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 11:59:02 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id 6so433326998qgy.1
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 08:59:02 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id k9si14149425qge.20.2016.01.15.08.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 08:59:02 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id y67so4649237qkc.1
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 08:59:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5693A77E.4020809@linux.intel.com>
References: <1447247184-27939-1-git-send-email-sakari.ailus@linux.intel.com>
	<20151202162558.d0465f11746ff94114c5d987@linux-foundation.org>
	<5693A77E.4020809@linux.intel.com>
Date: Fri, 15 Jan 2016 08:59:01 -0800
Message-ID: <CAA9_cmeneVE_VvCz_6=oOL6+_ZzFscv9P9b9nO8GkR=QpwgW_g@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: EXPORT_SYMBOL_GPL(find_vm_area);
From: Dan Williams <dan.j.williams@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Mon, Jan 11, 2016 at 5:00 AM, Sakari Ailus
<sakari.ailus@linux.intel.com> wrote:
> Hi Andrew,
>
> Andrew Morton wrote:
>> On Wed, 11 Nov 2015 15:06:24 +0200 Sakari Ailus <sakari.ailus@linux.intel.com> wrote:
>>
>>> find_vm_area() is needed in implementing the DMA mapping API as a module.
>>> Device specific IOMMUs with associated DMA mapping implementations should be
>>> buildable as modules.
>>>
>>> ...
>>>
>>> --- a/mm/vmalloc.c
>>> +++ b/mm/vmalloc.c
>>> @@ -1416,6 +1416,7 @@ struct vm_struct *find_vm_area(const void *addr)
>>>
>>>      return NULL;
>>>  }
>>> +EXPORT_SYMBOL_GPL(find_vm_area);
>>
>> Confused.  Who is setting CONFIG_HAS_DMA=m?
>>
>
> Apologies for the late reply --- CONFIG_HAS_DMA isn't configured as a
> module, but some devices are not DMA coherent even on x86. The existing
> x86 DMA mapping implementation doesn't quite work for those at the
> moment, and nothing prevents using another one (and as a module, in
> which case this patch is required).

Why not teach the DMA mapping api how to do cache management for such
devices?  Why would you need find_vm_area() exported?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
