Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A5D816B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 02:58:10 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LSW00K7J3CVKO@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 11 Oct 2011 07:58:07 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LSW00I8O3CVTT@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Oct 2011 07:58:07 +0100 (BST)
Date: Tue, 11 Oct 2011 08:57:56 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv16 0/9] Contiguous Memory Allocator
In-reply-to: <20111010155642.38df59af.akpm@linux-foundation.org>
Message-id: <00af01cc87e3$1b05e980$5111bc80$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <201110071827.06366.arnd@arndb.de>
 <20111010155642.38df59af.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>, 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>

Hello,

On Tuesday, October 11, 2011 12:57 AM Andrew Morton wrote:

> On Fri, 7 Oct 2011 18:27:06 +0200 Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > On Thursday 06 October 2011, Marek Szyprowski wrote:
> > > Once again I decided to post an updated version of the Contiguous Memory
> > > Allocator patches.
> > >
> > > This version provides mainly a bugfix for a very rare issue that might
> > > have changed migration type of the CMA page blocks resulting in dropping
> > > CMA features from the affected page block and causing memory allocation
> > > to fail. Also the issue reported by Dave Hansen has been fixed.
> > >
> > > This version also introduces basic support for x86 architecture, what
> > > allows wide testing on KVM/QEMU emulators and all common x86 boxes. I
> > > hope this will result in wider testing, comments and easier merging to
> > > mainline.
> >
> > Hi Marek,
> >
> > I think we need to finally get this into linux-next now, to get some
> > broader testing. Having the x86 patch definitely helps here becauses
> > it potentially exposes the code to many more testers.
> >
> > IMHO it would be good to merge the entire series into 3.2, since
> > the ARM portion fixes an important bug (double mapping of memory
> > ranges with conflicting attributes) that we've lived with for far
> > too long, but it really depends on how everyone sees the risk
> > for regressions here. If something breaks in unfixable ways before
> > the 3.2 release, we can always revert the patches and have another
> > try later.
> >
> > It's also not clear how we should merge it. Ideally the first bunch
> > would go through linux-mm, and the architecture specific patches
> > through the respective architecture trees, but there is an obvious
> > inderdependency between these sets.
> >
> > Russell, Andrew, are you both comfortable with putting the entire
> > set into linux-mm to solve this? Do you see this as 3.2 or rather
> > as 3.3 material?
> >
> 
> Russell's going to hate me, but...
> 
> I do know that he had substantial objections to at least earlier
> versions of this, and he is a guy who knows of what he speaks.

I've did my best to fix these issues. I'm still waiting for comments...

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
