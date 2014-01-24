Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 696046B0037
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 13:51:43 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id 6so1384410bkj.15
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:51:42 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id q2si4045106bkr.171.2014.01.24.10.51.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 10:51:42 -0800 (PST)
Received: by mail-ig0-f180.google.com with SMTP id m12so3349270iga.1
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:51:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E2B431.5090705@intel.com>
References: <52E19C7D.7050603@intel.com>
	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>
	<52E28067.1060507@intel.com>
	<CAE9FiQVy+8CF5qwnyL8YGzqwKOJF+y7N_+reAXWw7p8-BaVQPg@mail.gmail.com>
	<52E2AC5A.3000005@intel.com>
	<CAE9FiQW3DrGjKHLhwBgcK076g7z-6_-0EN2HwtVBLSpKO4m6-Q@mail.gmail.com>
	<52E2AEA3.2020907@intel.com>
	<CAE9FiQU795SWFfnQU=0STbQconSraac8heCNnkMpynY6fbi-4w@mail.gmail.com>
	<52E2B431.5090705@intel.com>
Date: Fri, 24 Jan 2014 10:51:40 -0800
Message-ID: <CAE9FiQUiFpBh3q9L9dDQymLor0hwoLy92aEU30vZ5Ga9p=zSNg@mail.gmail.com>
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 24, 2014 at 10:42 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 01/24/2014 10:24 AM, Yinghai Lu wrote:
>> On Fri, Jan 24, 2014 at 10:19 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>>> FWIW, I did turn of memblock=debug.  It eventually booted, but
>>> slooooooooooowly.
>>
>> then that is not a problem, as you are using 4k page mapping only.
>> and that printout is too spew...
>
> This means that, essentially, memblock=debug and
> KMEMCHECK/DEBUG_PAGEALLOC can't be used together.  That's a shame
> because my DEBUG_PAGEALLOC config *broke* this code a few months ago,
> right?  Oh well.

should only be broken when MOVABLE_NODE is enabled on big system.

>
>>> How many problems in this code are we tracking, btw?  This is at least
>>> 3, right?
>>
>> two problems:
>> 1. big numa system.
>> 2. Andrew's system with swiotlb.
>
> Can I ask politely for some more caution on your part in this area?
> This is two consecutive kernels where this code has broken my system.

I agree, the code get messy as now we have top_down and bottom up
mapping for different configuration.

I already tried hard to make parsing srat early solution instead that split.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
