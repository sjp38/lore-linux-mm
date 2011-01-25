Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 40B7A6B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:47:09 -0500 (EST)
Message-ID: <4D3F36CB.6060505@linux.intel.com>
Date: Tue, 25 Jan 2011 12:47:07 -0800
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/25] mm: Preemptibility -v7
References: <20110125173111.720927511@chello.nl>	 <m2ipxcsr6v.fsf@linux.intel.com> <1295987985.28776.1118.camel@laptop>
In-Reply-To: <1295987985.28776.1118.camel@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> Its nesting hundreds of spinlocks (255+) make the preempt debug code
> unhappy, it also causes fun latencies when you do start KVM/GRU
> Although arguably that's the least convincing reason to do all this its
> the one that got me to actually compose this series -- I really should
> write a new leader..
Least Convincing is a good description...
Tuning operations which only happen once is not very interesting, 
especially if that affects
fast paths.

> Making all this preemptible also allows making the whole mmu_gather
> thing preemptible, which is something we've wanted to do for a long
> while, it also allows XPMEM or whatever that thing was called (Andrea
> knows) and of course, it moves a part of -rt upstream.

I thought the reason for the preempt off inside the mmu gather region was
to stay on the same CPU for local/remote flushes. How would it change that?

> If we decide to keep patch 24, it also simplifies the truncate path
> quite a bit.
That sounds like a good thing. Making truncate simpler is always good.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
