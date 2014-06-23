Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB0F6B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 16:07:00 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id z11so5208071lbi.38
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 13:06:59 -0700 (PDT)
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
        by mx.google.com with ESMTPS id nc2si35730842lbc.35.2014.06.23.13.06.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 13:06:58 -0700 (PDT)
Received: by mail-lb0-f181.google.com with SMTP id p9so5144516lbv.26
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 13:06:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53A88806.1060908@intel.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu>
 <53A88806.1060908@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 23 Jun 2014 13:06:37 -0700
Message-ID: <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, Jun 23, 2014 at 1:03 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/23/2014 12:49 PM, Andy Lutomirski wrote:
>> On 06/18/2014 02:44 AM, Qiaowei Ren wrote:
>>> This patch adds one MPX specific mmap interface, which only handles
>>> mpx related maps, including bounds table and bounds directory.
>>>
>>> In order to track MPX specific memory usage, this interface is added
>>> to stick new vm_flag VM_MPX in the vma_area_struct when create a
>>> bounds table or bounds directory.
>>
>> I imagine the linux-mm people would want to think about any new vm flag.
>>  Why is this needed?
>
> These tables can take huge amounts of memory.  In the worst-case
> scenario, the tables can be 4x the size of the data structure being
> tracked.  IOW, a 1-page structure can require 4 bounds-table pages.
>
> My expectation is that folks using MPX are going to be keen on figuring
> out how much memory is being dedicated to it.  With this feature, plus
> some grepping in /proc/$pid/smaps one could take a pretty good stab at it.
>
> I know VM flags are scarce, and I'm open to other ways to skin this cat.
>

Can the new vm_operation "name" be use for this?  The magic "always
written to core dumps" feature might need to be reconsidered.

There's also arch_vma_name, but I just finished removing for x86, and
I'd be a little sad to see it come right back.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
