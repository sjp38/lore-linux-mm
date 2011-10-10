Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D5FCE6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 18:56:47 -0400 (EDT)
Received: by ggdk5 with SMTP id k5so6697278ggd.14
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 15:56:45 -0700 (PDT)
Date: Mon, 10 Oct 2011 15:56:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv16 0/9] Contiguous Memory Allocator
Message-Id: <20111010155642.38df59af.akpm@linux-foundation.org>
In-Reply-To: <201110071827.06366.arnd@arndb.de>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	<201110071827.06366.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, 7 Oct 2011 18:27:06 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Thursday 06 October 2011, Marek Szyprowski wrote:
> > Once again I decided to post an updated version of the Contiguous Memory
> > Allocator patches.
> > 
> > This version provides mainly a bugfix for a very rare issue that might
> > have changed migration type of the CMA page blocks resulting in dropping
> > CMA features from the affected page block and causing memory allocation
> > to fail. Also the issue reported by Dave Hansen has been fixed.
> > 
> > This version also introduces basic support for x86 architecture, what
> > allows wide testing on KVM/QEMU emulators and all common x86 boxes. I
> > hope this will result in wider testing, comments and easier merging to
> > mainline.
> 
> Hi Marek,
> 
> I think we need to finally get this into linux-next now, to get some
> broader testing. Having the x86 patch definitely helps here becauses
> it potentially exposes the code to many more testers.
> 
> IMHO it would be good to merge the entire series into 3.2, since
> the ARM portion fixes an important bug (double mapping of memory
> ranges with conflicting attributes) that we've lived with for far
> too long, but it really depends on how everyone sees the risk
> for regressions here. If something breaks in unfixable ways before
> the 3.2 release, we can always revert the patches and have another
> try later.
> 
> It's also not clear how we should merge it. Ideally the first bunch
> would go through linux-mm, and the architecture specific patches
> through the respective architecture trees, but there is an obvious
> inderdependency between these sets.
> 
> Russell, Andrew, are you both comfortable with putting the entire
> set into linux-mm to solve this? Do you see this as 3.2 or rather
> as 3.3 material?
> 

Russell's going to hate me, but...

I do know that he had substantial objections to at least earlier
versions of this, and he is a guy who knows of what he speaks.

So I would want to get a nod from rmk on this work before proceeding. 
If that nod isn't available then let's please identify the issues and
see what we can do about them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
