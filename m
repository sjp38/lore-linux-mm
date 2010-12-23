Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 433196B0092
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 09:17:18 -0500 (EST)
Date: Thu, 23 Dec 2010 14:16:08 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
Message-ID: <20101223141608.GM3636@n2100.arm.linux.org.uk>
References: <cover.1292443200.git.m.nazarewicz@samsung.com> <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com> <20101223100642.GD3636@n2100.arm.linux.org.uk> <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com> <20101223121917.GG3636@n2100.arm.linux.org.uk> <4D135004.3070904@samsung.com> <20101223134838.GK3636@n2100.arm.linux.org.uk> <4D1356D7.2000008@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D1356D7.2000008@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Tomasz Fujak <t.fujak@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Kyungmin Park' <kmpark@infradead.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Ankita Garg' <ankita@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 03:04:07PM +0100, Tomasz Fujak wrote:
> On 2010-12-23 14:48, Russell King - ARM Linux wrote:
> > On Thu, Dec 23, 2010 at 02:35:00PM +0100, Tomasz Fujak wrote:
> >> Dear Mr. King,
> >>
> >> AFAIK the CMA is the fourth attempt since 2008 taken to solve the
> >> multimedia memory allocation issue on some embedded devices. Most
> >> notably on ARM, that happens to be present in the SoCs we care about
> >> along the IOMMU-incapable multimedia IPs.
> >>
> >> I understand that you have your guidelines taken from the ARM
> >> specification, but this approach is not helping us.
> > I'm sorry you feel like that, but I'm living in reality.  If we didn't
> > have these architecture restrictions then we wouldn't have this problem
> > in the first place.
> Do we really have them, or just the documents say they exist?

Yes.  We have seen CPUs which lockup or crash as a result of mismatched
attributes in the page tables.

> > What I'm trying to do here is to ensure that we remain _legal_ to the
> > architecture specification - which for this issue means that we avoid
> > corrupting people's data.
> As legal as the mentioned dma_coherent?

See my other comment in an earlier email.  See the patch which prevents
ioremap() being used on system memory.  There is active movement at the
present time to sorting these violations out and find solutions for
them.

The last thing we need is a new API which introduces new violations.

> > Maybe you like having a system which randomly corrupts people's data?
> > I most certainly don't.  But that's the way CMA is heading at the moment
> > on ARM.
> Has this been experienced? I had some ARM-compatible boards on my desk
> (xscale, v6 and v7) and none of them crashed due to this behavior. And
> we *do* have multiple memory mappings, with different attributes.

Xscale doesn't suffer from the problem.  V6 doesn't aggressively speculate.
V7 speculates more aggressively, and corruption has been seen there.

> > It is not up to me to solve these problems - that's for the proposer of
> > the new API to do so.  So, please, don't try to lump this problem on
> > my shoulders.  It's not my problem to sort out.
> Just great. Nothing short of spectacular - this way the IA32 is going to
> take the embedded market piece by piece once the big two advance their
> foundry processes.

Look, I've been pointing out this problem ever since the very _first_
CMA patches were posted to the list, yet the CMA proponents have decided
to brush those problems aside each and every time I've raised them.

So, you should be asking _why_ the CMA proponents are choosing to ignore
this issue completely, rather than working to resolve it.

If it's resolved, then the problem goes away.

> In other words, should we take your response as yet another NAK?
> Or would you try harder and at least point us to some direction that
> would not doom the effort from the very beginning.

What the fsck do you think I've been doing?  This is NOT THE FIRST time
I've raised this issue.  I gave up raising it after the first couple
of attempts because I wasn't being listened to.

You say about _me_ not being very helpful.  How about the CMA proponents
start taking the issue I've raised seriously, and try to work out how
to solve it?  And how about blaming them for the months of wasted time
on this issue _because_ _they_ have chosen to ignore it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
