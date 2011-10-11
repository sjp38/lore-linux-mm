Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 672746B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 09:53:47 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv16 0/9] Contiguous Memory Allocator
Date: Tue, 11 Oct 2011 15:52:04 +0200
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com> <201110071827.06366.arnd@arndb.de> <20111010155642.38df59af.akpm@linux-foundation.org>
In-Reply-To: <20111010155642.38df59af.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201110111552.04615.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Paul McKenney <paul.mckenney@linaro.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Tuesday 11 October 2011, Andrew Morton wrote:
> Russell's going to hate me, but...
> 
> I do know that he had substantial objections to at least earlier
> versions of this, and he is a guy who knows of what he speaks.
> 
> So I would want to get a nod from rmk on this work before proceeding. 
> If that nod isn't available then let's please identify the issues and
> see what we can do about them.

I'm pretty sure that Russell's concerns were almost entirely about the
ARM specific parts, which were extremely hard to figure out. The
most important technical concern back in July was that the patch
series at the time did not address the problem of conflicting pte
flags when we remap memory as uncached on ARMv6. He had a patch
to address this problem that was supposed to get merged in 3.1
and would have conflicted with the CMA patch set.

Things have changed a lot since then. Russell had to revert his
own patch because he found regressions using it on older machines.
However, the current CMA on ARM patch AFAICT reliably fixes this
problem now and does not cause the same regression on older machines.
The solution used now is the one we agreed on after sitting together
for a few hours with Russell, Marek, Paul McKenney and myself.

If there are still concerns over the ARM specific portion of
the patch series, I'm very confident that we can resolve these
now (I was much less so before that meeting).

What I would really want to hear from you is your opinion on
the architecture independent stuff. Obviously, ARM is the
most important consumer of the patch set, but I think the
code has its merit on other architectures as well and most of
them (maybe not parisc) should be about as simple as the x86
one that Marek posted now with v16.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
