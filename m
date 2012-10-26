Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 920796B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 08:48:14 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from ptep_set_access_flags()
References: <20121025121617.617683848@chello.nl>
	<20121025124832.840241082@chello.nl>
	<CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
	<5089F5B5.1050206@redhat.com>
	<CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
	<508A0A0D.4090001@redhat.com>
	<CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
	<CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
Date: Fri, 26 Oct 2012 05:48:03 -0700
In-Reply-To: <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
	(Michel Lespinasse's message of "Fri, 26 Oct 2012 05:34:02 -0700")
Message-ID: <m2pq45qu0s.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

Michel Lespinasse <walken@google.com> writes:

> On Thu, Oct 25, 2012 at 9:23 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>> On Thu, Oct 25, 2012 at 8:57 PM, Rik van Riel <riel@redhat.com> wrote:
>>>
>>> That may not even be needed.  Apparently Intel chips
>>> automatically flush an entry from the TLB when it
>>> causes a page fault.  I assume AMD chips do the same,
>>> because flush_tlb_fix_spurious_fault evaluates to
>>> nothing on x86.
>>
>> Yes. It's not architected as far as I know, though. But I agree, it's
>> possible - even likely - we could avoid TLB flushing entirely on x86.
>
> Actually, it is architected on x86. This was first described in the
> intel appnote 317080 "TLBs, Paging-Structure Caches, and Their
> Invalidation", last paragraph of section 5.1. Nowadays, the same
> contents are buried somewhere in Volume 3 of the architecture manual
> (in my copy: 4.10.4.1 Operations that Invalidate TLBs and
> Paging-Structure Caches)

This unfortunately would only work for processes with no threads
because it only works on the current logical CPU.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
