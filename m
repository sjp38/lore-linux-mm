Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3E46B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 13:43:05 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so3614030pad.28
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:43:05 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wm3si2096913pab.136.2014.01.24.10.43.03
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 10:43:04 -0800 (PST)
Message-ID: <52E2B431.5090705@intel.com>
Date: Fri, 24 Jan 2014 10:42:57 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
References: <52E19C7D.7050603@intel.com>	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>	<52E28067.1060507@intel.com>	<CAE9FiQVy+8CF5qwnyL8YGzqwKOJF+y7N_+reAXWw7p8-BaVQPg@mail.gmail.com>	<52E2AC5A.3000005@intel.com>	<CAE9FiQW3DrGjKHLhwBgcK076g7z-6_-0EN2HwtVBLSpKO4m6-Q@mail.gmail.com>	<52E2AEA3.2020907@intel.com> <CAE9FiQU795SWFfnQU=0STbQconSraac8heCNnkMpynY6fbi-4w@mail.gmail.com>
In-Reply-To: <CAE9FiQU795SWFfnQU=0STbQconSraac8heCNnkMpynY6fbi-4w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 01/24/2014 10:24 AM, Yinghai Lu wrote:
> On Fri, Jan 24, 2014 at 10:19 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>> FWIW, I did turn of memblock=debug.  It eventually booted, but
>> slooooooooooowly.
> 
> then that is not a problem, as you are using 4k page mapping only.
> and that printout is too spew...

This means that, essentially, memblock=debug and
KMEMCHECK/DEBUG_PAGEALLOC can't be used together.  That's a shame
because my DEBUG_PAGEALLOC config *broke* this code a few months ago,
right?  Oh well.

>> How many problems in this code are we tracking, btw?  This is at least
>> 3, right?
> 
> two problems:
> 1. big numa system.
> 2. Andrew's system with swiotlb.

Can I ask politely for some more caution on your part in this area?
This is two consecutive kernels where this code has broken my system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
