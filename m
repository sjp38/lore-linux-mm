Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B32266B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 08:49:38 -0500 (EST)
Date: Thu, 23 Dec 2010 13:48:38 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
Message-ID: <20101223134838.GK3636@n2100.arm.linux.org.uk>
References: <cover.1292443200.git.m.nazarewicz@samsung.com> <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com> <20101223100642.GD3636@n2100.arm.linux.org.uk> <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com> <20101223121917.GG3636@n2100.arm.linux.org.uk> <4D135004.3070904@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D135004.3070904@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Tomasz Fujak <t.fujak@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Kyungmin Park' <kmpark@infradead.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Ankita Garg' <ankita@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 02:35:00PM +0100, Tomasz Fujak wrote:
> Dear Mr. King,
> 
> AFAIK the CMA is the fourth attempt since 2008 taken to solve the
> multimedia memory allocation issue on some embedded devices. Most
> notably on ARM, that happens to be present in the SoCs we care about
> along the IOMMU-incapable multimedia IPs.
> 
> I understand that you have your guidelines taken from the ARM
> specification, but this approach is not helping us.

I'm sorry you feel like that, but I'm living in reality.  If we didn't
have these architecture restrictions then we wouldn't have this problem
in the first place.

What I'm trying to do here is to ensure that we remain _legal_ to the
architecture specification - which for this issue means that we avoid
corrupting people's data.

Maybe you like having a system which randomly corrupts people's data?
I most certainly don't.  But that's the way CMA is heading at the moment
on ARM.

It is not up to me to solve these problems - that's for the proposer of
the new API to do so.  So, please, don't try to lump this problem on
my shoulders.  It's not my problem to sort out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
