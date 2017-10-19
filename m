Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC9B26B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:05:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n4so3596138wrb.8
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:05:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z67sor82037wrc.26.2017.10.19.01.05.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 01:05:55 -0700 (PDT)
Date: Thu, 19 Oct 2017 10:05:53 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171019080553.s22nd7j2t22cimyx@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <20171018100944.g2mc6yorhtm5piom@gmail.com>
 <20171019043240.GA3310@X58A-UD3R>
 <20171019055730.mlpoz333ekflacs2@gmail.com>
 <20171019061112.GB3310@X58A-UD3R>
 <20171019062212.n55vzg4khtds3mqk@gmail.com>
 <20171019063610.GD3310@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019063610.GD3310@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Linus Torvalds <torvalds@linux-foundation.org>


* Byungchul Park <byungchul.park@lge.com> wrote:

> On Thu, Oct 19, 2017 at 08:22:12AM +0200, Ingo Molnar wrote:
> > There's no current crash regression that I know of - I'm just outlining the 
> > conditions of getting all this re-enabled in the next merge window.
> > 
> > Instead of sending two series, could you please send a series that includes both 
> > these fixing + re-enabling patches, plus the false positive fixes?
> > 
> > In particular I think the cross-release re-enabling should be done as the last 
> > patch, so that any future bisections of new false positives won't be made more 
> > difficult by re-introducing the old false positives near the end of the bisection.
> 
> I agree. But I already sent v2 before you told me..
> 
> Do you want me to send patches fixing false positives in the thread
> fixing performance regression?

No need, I'll reorder them and let you know if there's any problem left.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
