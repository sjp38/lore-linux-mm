Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 63CA36B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 12:11:36 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so5896273lbi.41
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:11:35 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id mz5si14654067wic.67.2014.05.28.09.11.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 May 2014 09:11:33 -0700 (PDT)
Message-ID: <53860AAD.3080107@nod.at>
Date: Wed, 28 May 2014 18:11:25 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>	<1401260039-18189-2-git-send-email-minchan@kernel.org>	<CAFLxGvyV2Upn7+uTtScu2_LGazy9L+HU9DWEC==0qyZphCrauA@mail.gmail.com> <20140528120817.71921d6a@gandalf.local.home>
In-Reply-To: <20140528120817.71921d6a@gandalf.local.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>

Am 28.05.2014 18:08, schrieb Steven Rostedt:
> On Wed, 28 May 2014 17:43:50 +0200
> Richard Weinberger <richard.weinberger@gmail.com> wrote:
> 
> 
>>> diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
>>> index 8de6d9cf3b95..678205195ae1 100644
>>> --- a/arch/x86/include/asm/page_64_types.h
>>> +++ b/arch/x86/include/asm/page_64_types.h
>>> @@ -1,7 +1,7 @@
>>>  #ifndef _ASM_X86_PAGE_64_DEFS_H
>>>  #define _ASM_X86_PAGE_64_DEFS_H
>>>
>>> -#define THREAD_SIZE_ORDER      1
>>> +#define THREAD_SIZE_ORDER      2
>>>  #define THREAD_SIZE  (PAGE_SIZE << THREAD_SIZE_ORDER)
>>>  #define CURRENT_MASK (~(THREAD_SIZE - 1))
>>
>> Do you have any numbers of the performance impact of this?
>>
> 
> What performance impact are you looking for? Now if the system is short
> on memory, it would probably cause issues in creating tasks. But other
> than that, I'm not sure what you are looking for.

Allocating more continuous memory for every thread is not cheap.
I'd assume that such a change will cause more pressure on the allocator.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
