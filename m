Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id EF5836B0072
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 18:00:40 -0500 (EST)
Date: Mon, 19 Nov 2012 23:00:35 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121119230034.GO8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121119223604.GA13470@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 11:36:04PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > Ok.
> > 
> > In response to one of your later questions, I found that I had 
> > in fact disabled THP without properly reporting it. [...]
> 
> Hugepages is a must for most forms of NUMA/HPC.

Requiring huge pages to avoid a regression is a mistake.

> This alone 
> questions the relevance of most of your prior numa/core testing 
> results. I now have to strongly dispute your other conclusions 
> as well.
> 

I'll freely admit that disabling THP for specjbb was a mistake and I should
have caught why at the start. However, the autonumabench figures reported for
the last release had THP enabled as had the kernel build benchmark figures.

> Just a look at 'perf top' output should have told you the story.
> 

I knew THP were not in use and said so in earlier reports. Take this for
example -- https://lkml.org/lkml/2012/11/16/207 . For specjbb, note that
the THP fault alloc figures are close to 0 and due to that I said "THP is
not really a factor for this workload". What I failed to do was identify
why THP was not in use.

> Yet time and time again you readily reported bad 'schednuma' 
> results for a slow 4K memory model that neither we nor other 
> NUMA testers I talked to actually used, without stopping to look 
> why that was so...
> 

Again, I apologise for the THP mistake. The fact remains that the other
implementations did not suffer a performance slowdown due to the same
mistake.

> [ I suspect that if such terabytes-of-data workloads are forced 
>   through such a slow 4K pages model then there's a bug or 
>   mis-tuning in our code that explains the level of additional 
>   slowdown you saw - we'll fix that.
> 
>   But you should know that behavior under the slow 4K model 
>   tells very little about the true scheduling and placement 
>   quality of the patches... ]
> 
> Please report proper THP-enabled numbers before continuing.
> 

Will do. Are THP-disabled benchmark results to be ignored?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
