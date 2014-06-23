Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5702B6B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 16:03:49 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so6330314pad.9
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 13:03:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qd5si23311218pbb.211.2014.06.23.13.03.48
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 13:03:48 -0700 (PDT)
Message-ID: <53A88806.1060908@intel.com>
Date: Mon, 23 Jun 2014 13:03:18 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com> <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu>
In-Reply-To: <53A884B2.5070702@mit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 06/23/2014 12:49 PM, Andy Lutomirski wrote:
> On 06/18/2014 02:44 AM, Qiaowei Ren wrote:
>> This patch adds one MPX specific mmap interface, which only handles
>> mpx related maps, including bounds table and bounds directory.
>>
>> In order to track MPX specific memory usage, this interface is added
>> to stick new vm_flag VM_MPX in the vma_area_struct when create a
>> bounds table or bounds directory.
> 
> I imagine the linux-mm people would want to think about any new vm flag.
>  Why is this needed?

These tables can take huge amounts of memory.  In the worst-case
scenario, the tables can be 4x the size of the data structure being
tracked.  IOW, a 1-page structure can require 4 bounds-table pages.

My expectation is that folks using MPX are going to be keen on figuring
out how much memory is being dedicated to it.  With this feature, plus
some grepping in /proc/$pid/smaps one could take a pretty good stab at it.

I know VM flags are scarce, and I'm open to other ways to skin this cat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
