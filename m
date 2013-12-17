Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id CA2126B0036
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:15:00 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id t61so5921287wes.25
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:15:00 -0800 (PST)
Received: from mail-ea0-x236.google.com (mail-ea0-x236.google.com [2a00:1450:4013:c01::236])
        by mx.google.com with ESMTPS id ds14si5299991wic.2.2013.12.17.05.15.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:15:00 -0800 (PST)
Received: by mail-ea0-f182.google.com with SMTP id a15so2891553eae.27
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:14:59 -0800 (PST)
Date: Tue, 17 Dec 2013 14:14:56 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
Message-ID: <20131217131456.GA28688@gmail.com>
References: <1386849309-22584-3-git-send-email-mgorman@suse.de>
 <20131212131309.GD5806@gmail.com>
 <52A9BC3A.7010602@linaro.org>
 <20131212141147.GB17059@gmail.com>
 <52AA5C92.7030207@linaro.org>
 <52AA6CB9.60302@linaro.org>
 <20131214141902.GA16438@laptop.programming.kicks-ass.net>
 <20131214142741.GB16438@laptop.programming.kicks-ass.net>
 <20131216135901.GA6171@gmail.com>
 <52B03C84.1000600@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B03C84.1000600@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>


* Alex Shi <alex.shi@linaro.org> wrote:

> > Building the kernel is obviously a prime workload - and given that 
> > the kernel is active only about 10% of the time for a typical 
> > kernel build, a 1-2% speedup means a 10-20% speedup in kernel 
> > performance (which sounds a bit too good at first glance).
> 
> Maybe a extra time tlb flush causes more tlb refill that cost much 
> user space time.

All these things are measurable, that way maybes can be converted into 
certainty.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
