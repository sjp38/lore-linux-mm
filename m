Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 960BD6B0037
	for <linux-mm@kvack.org>; Thu,  1 May 2014 06:04:52 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so2903383wes.29
        for <linux-mm@kvack.org>; Thu, 01 May 2014 03:04:52 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id bz14si591654wib.6.2014.05.01.03.04.50
        for <linux-mm@kvack.org>;
        Thu, 01 May 2014 03:04:51 -0700 (PDT)
Date: Thu, 1 May 2014 11:04:15 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH V4 6/7] arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
Message-ID: <20140501100415.GC22316@arm.com>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
 <1396018892-6773-7-git-send-email-steve.capper@linaro.org>
 <20140430152047.GF31220@arm.com>
 <20140430153317.GG31220@arm.com>
 <20140430153824.GA7166@linaro.org>
 <20140430172114.GI31220@arm.com>
 <20140501073402.GA30358@linaro.org>
 <20140501095246.GB22316@arm.com>
 <20140501095739.GO11096@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140501095739.GO11096@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steve Capper <steve.capper@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Thu, May 01, 2014 at 10:57:39AM +0100, Peter Zijlstra wrote:
> On Thu, May 01, 2014 at 10:52:47AM +0100, Catalin Marinas wrote:
> > Does gup_fast walking increment the mm_users? Or is it a requirement of
> > the calling code? I can't seem to find where this happens.
> 
> No, its not required at all. One should only walk current->mm with
> gup_fast, any other usage is broken.

OK, I get it now.

> And by delaying TLB shootdown, either through disabling IRQs and
> stalling IPIs or by using RCU freeing, you're guaranteed your own page
> tables won't disappear underneath your feet.

And for RCU to work, we still need to use the full tlb_remove_table()
logic (Steve's patches just use tlb_remove_page() for table freeing).

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
