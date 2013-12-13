Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 698686B0092
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 08:35:56 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so867256eaj.37
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 05:35:55 -0800 (PST)
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
        by mx.google.com with ESMTPS id i1si1854964eev.236.2013.12.13.05.35.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 05:35:55 -0800 (PST)
Received: by mail-ea0-f169.google.com with SMTP id l9so762199eaj.28
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 05:35:20 -0800 (PST)
Date: Fri, 13 Dec 2013 14:35:17 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 0/3] Fix ebizzy performance regression on IvyBridge
 due to X86 TLB range flush
Message-ID: <20131213133517.GA11176@gmail.com>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <20131212130107.GC5806@gmail.com>
 <20131212144029.GI11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212144029.GI11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > [...]
> >
> > stddev appears to be rather large especially around a client count 
> > of 7-8. It will be difficult to fine-tune the TLB range flush 
> > constants if noise is too large.
> 
> The number of iterations were very low to have high confidence of 
> the figures. The high standard deviation for 5 clients was a single 
> large outlier. It potentially could be stabilised to some extent by 
> bumping up the number of iterations a lot and using percentiles 
> instead of means.

Fair enough - and you were bisecting so length of runtime and 
confidence of detection were obviously the primary concerns.

> I'm a bit wary of optimising the TLB flush ranges based on the 
> benchmark even if we stabilised the figures. [...]

Absolutely - but they do appear to be pretty 'adversarial' to the TLB 
optimization, with a measurable slowdown in a pretty complex, 
real-life workload pattern.

So future tuning efforts will have to take such workloads into effect 
as well, to make sure we don't regress again.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
