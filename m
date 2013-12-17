Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id CBC686B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 09:42:33 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id t60so6082514wes.6
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 06:42:33 -0800 (PST)
Received: from mail-ea0-x230.google.com (mail-ea0-x230.google.com [2a00:1450:4013:c01::230])
        by mx.google.com with ESMTPS id i10si5812557wix.57.2013.12.17.06.42.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 06:42:32 -0800 (PST)
Received: by mail-ea0-f176.google.com with SMTP id h14so2943380eaj.7
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 06:42:32 -0800 (PST)
Date: Tue, 17 Dec 2013 15:42:14 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131217144214.GA12370@gmail.com>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
 <20131217110051.GA27701@gmail.com>
 <20131217143253.GB11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217143253.GB11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> [...]
>
> At that point it'll be time to look at profiles and see where we are 
> actually spending time because the possibilities of finding things 
> to fix through bisection will be exhausted.

Yeah.

One (heavy handed but effective) trick that can be used in such a 
situation is to just revert everything that is causing problems, and 
continue reverting until we get back to a v3.4 baseline performance.

Once such a 'clean' tree (or queue of patches) is achived, that can be 
used as a measurement base and the individual features can be 
re-applied again, one by one, with measurement and analysis becoming a 
lot easier.

> > Also it appears the Ebizzy numbers ought to be stable enough now 
> > to make the range-TLB-flush measurements more precise?
> 
> Right now, the tlbflush microbenchmark figures look awful on the 
> 8-core machine when the tlbflush shift patch and the schedule domain 
> fix are both applied.

I think that furthr strengthens the case for the 'clean base' approach 
I outlined above - but it's your call obviously ...

Thanks again for going through all this. Tracking multi-commit 
performance regressions across 1.5 years worth of commits is generally 
very hard. Does your testing effort comes from enterprise Linux QA 
testing, or did you ran into this problem accidentally?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
