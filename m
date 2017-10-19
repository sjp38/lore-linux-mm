Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE1A26B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:36:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t10so5938872pgo.20
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 23:36:13 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y69si8617980pfb.303.2017.10.18.23.36.12
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 23:36:12 -0700 (PDT)
Date: Thu, 19 Oct 2017 15:36:11 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171019063610.GD3310@X58A-UD3R>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <20171018100944.g2mc6yorhtm5piom@gmail.com>
 <20171019043240.GA3310@X58A-UD3R>
 <20171019055730.mlpoz333ekflacs2@gmail.com>
 <20171019061112.GB3310@X58A-UD3R>
 <20171019062212.n55vzg4khtds3mqk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019062212.n55vzg4khtds3mqk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Oct 19, 2017 at 08:22:12AM +0200, Ingo Molnar wrote:
> There's no current crash regression that I know of - I'm just outlining the 
> conditions of getting all this re-enabled in the next merge window.
> 
> Instead of sending two series, could you please send a series that includes both 
> these fixing + re-enabling patches, plus the false positive fixes?
> 
> In particular I think the cross-release re-enabling should be done as the last 
> patch, so that any future bisections of new false positives won't be made more 
> difficult by re-introducing the old false positives near the end of the bisection.

I agree. But I already sent v2 before you told me..

Do you want me to send patches fixing false positives in the thread
fixing performance regression?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
