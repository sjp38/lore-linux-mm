Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C18576B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 06:59:12 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so4349574pad.17
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:59:12 -0800 (PST)
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
        by mx.google.com with ESMTPS id sj5si11608023pab.81.2013.12.17.03.59.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 03:59:11 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so6857810pbb.23
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:59:10 -0800 (PST)
Message-ID: <52B03C84.1000600@linaro.org>
Date: Tue, 17 Dec 2013 19:59:00 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
References: <1386849309-22584-1-git-send-email-mgorman@suse.de> <1386849309-22584-3-git-send-email-mgorman@suse.de> <20131212131309.GD5806@gmail.com> <52A9BC3A.7010602@linaro.org> <20131212141147.GB17059@gmail.com> <52AA5C92.7030207@linaro.org> <52AA6CB9.60302@linaro.org> <20131214141902.GA16438@laptop.programming.kicks-ass.net> <20131214142741.GB16438@laptop.programming.kicks-ass.net> <20131216135901.GA6171@gmail.com>
In-Reply-To: <20131216135901.GA6171@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>

On 12/16/2013 09:59 PM, Ingo Molnar wrote:
> So if the kbuild speedup of 1-2% is true and reproducable then that 
> might be worth doing.

I have a Intel desktop and need it for daily works. Wonder if Intel guys
like to have a try? I assume the patch is already in Fengguang's testing
system.
> 
> Building the kernel is obviously a prime workload - and given that the 
> kernel is active only about 10% of the time for a typical kernel 
> build, a 1-2% speedup means a 10-20% speedup in kernel performance 
> (which sounds a bit too good at first glance).

Maybe a extra time tlb flush causes more tlb refill that cost much user
space time.
-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
