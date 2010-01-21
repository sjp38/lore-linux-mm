Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B132D6B007D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:51:54 -0500 (EST)
Message-ID: <4B58770A.3050107@zytor.com>
Date: Thu, 21 Jan 2010 07:47:22 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
References: <1262700774-1808-5-git-send-email-gleb@redhat.com> <1263490267.4244.340.camel@laptop> <20100117144411.GI31692@redhat.com> <4B541D08.9040802@zytor.com> <20100118085022.GA30698@redhat.com> <4B5510B1.9010202@zytor.com> <20100119065537.GF14345@redhat.com> <4B55E5D8.1070402@zytor.com> <20100119174438.GA19450@redhat.com> <4B5611A9.4050301@zytor.com> <20100120100254.GC5238@redhat.com> <4B5740CD.4020005@zytor.com> <4B58181B.60405@redhat.com>
In-Reply-To: <4B58181B.60405@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/21/2010 01:02 AM, Avi Kivity wrote:
>>
>> You can also just emulate the state transition -- since you know
>> you're dealing with a flat protected-mode or long-mode OS (and just
>> make that a condition of enabling the feature) you don't have to deal
>> with all the strange combinations of directions that an unrestricted
>> x86 event can take.  Since it's an exception, it is unconditional.
> 
> Do you mean create the stack frame manually?  I'd really like to avoid
> that for many reasons, one of which is performance (need to do all the
> virt-to-phys walks manually), the other is that we're certain to end up
> with something horribly underspecified.  I'd really like to keep as
> close as possible to the hardware.  For the alternative approach, see Xen.
> 

I obviously didn't mean to do something which didn't look like a
hardware-delivered exception.  That by itself provides a tight spec.
The performance issue is real, of course.

Obviously, the design of VT-x was before my time at Intel, so I'm not
familiar with why the tradeoffs that were done they way they were.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
