Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 8A82B6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:28:59 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so1272830eek.14
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 06:28:57 -0700 (PDT)
Date: Fri, 26 Oct 2012 15:28:53 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from
 ptep_set_access_flags()
Message-ID: <20121026132853.GA11178@gmail.com>
References: <20121025124832.840241082@chello.nl>
 <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
 <5089F5B5.1050206@redhat.com>
 <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
 <508A0A0D.4090001@redhat.com>
 <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <m2pq45qu0s.fsf@firstfloor.org>
 <508A8D31.9000106@redhat.com>
 <20121026132601.GC9886@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121026132601.GC9886@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Ingo Molnar <mingo@kernel.org> wrote:

> [...]
> 
> Rik, mind sending an updated patch that addresses Linus's 
> concerns, or should I code it up if you are busy?
> 
> We can also certainly try the second patch, but I'd do it at 
> the end of the series, to put some tree distance between the 
> two patches, to not concentrate regression risks too tightly 
> in the Git space, to help out with hard to bisect problems...

I'd also like to have the second patch separately because I'd 
like to measure spurious fault frequency before and after the 
change, with a reference workload.

Just a single page fault, even it's a minor one, might make a 
micro-optimization a net loss. INVLPG might be the cheaper 
option on average - it needs to be measured. (I'll do that, just 
please keep it separate from the main TLB-flush optimization.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
