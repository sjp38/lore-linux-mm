Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 293596B0173
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 19:19:57 -0400 (EDT)
Received: by ywe9 with SMTP id 9so3624381ywe.14
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 16:19:55 -0700 (PDT)
Date: Fri, 14 Oct 2011 16:19:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv16 0/9] Contiguous Memory Allocator
Message-Id: <20111014161951.5b4bb327.akpm@linux-foundation.org>
In-Reply-To: <201110111552.04615.arnd@arndb.de>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	<201110071827.06366.arnd@arndb.de>
	<20111010155642.38df59af.akpm@linux-foundation.org>
	<201110111552.04615.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Paul McKenney <paul.mckenney@linaro.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <jweiner@redhat.com>

On Tue, 11 Oct 2011 15:52:04 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Tuesday 11 October 2011, Andrew Morton wrote:
> > Russell's going to hate me, but...
> > 
> > I do know that he had substantial objections to at least earlier
> > versions of this, and he is a guy who knows of what he speaks.
> > 
> > So I would want to get a nod from rmk on this work before proceeding. 
> > If that nod isn't available then let's please identify the issues and
> > see what we can do about them.
> 
> I'm pretty sure that Russell's concerns were almost entirely about the
> ARM specific parts, which were extremely hard to figure out. The
> most important technical concern back in July was that the patch
> series at the time did not address the problem of conflicting pte
> flags when we remap memory as uncached on ARMv6. He had a patch
> to address this problem that was supposed to get merged in 3.1
> and would have conflicted with the CMA patch set.
> 
> Things have changed a lot since then. Russell had to revert his
> own patch because he found regressions using it on older machines.
> However, the current CMA on ARM patch AFAICT reliably fixes this
> problem now and does not cause the same regression on older machines.
> The solution used now is the one we agreed on after sitting together
> for a few hours with Russell, Marek, Paul McKenney and myself.
> 
> If there are still concerns over the ARM specific portion of
> the patch series, I'm very confident that we can resolve these
> now (I was much less so before that meeting).
> 
> What I would really want to hear from you is your opinion on
> the architecture independent stuff. Obviously, ARM is the
> most important consumer of the patch set, but I think the
> code has its merit on other architectures as well and most of
> them (maybe not parisc) should be about as simple as the x86
> one that Marek posted now with v16.

Having an x86 implementation is good.  It would also be good to get
some x86 drivers using CMA asap, so the thing gets some runtime testing
from the masses.  Can we think of anything we can do here?

Regarding the core MM changes: Mel's the man for migration and
compaction.  I wouldn't want to proceed until he (and perferably
Johannes) have spent some quality time with the code.  I'm not seeing
their reviewed-by's of acked-by's and I don't have a good recollection
of their involvement?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
