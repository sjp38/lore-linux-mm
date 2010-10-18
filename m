Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8EDAA6B00DA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 17:00:00 -0400 (EDT)
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20101013144044.GS30667@csn.ul.ie>
References: <20101009095718.1775.qmail@kosh.dhis.org>
	 <20101011143022.GD30667@csn.ul.ie>
	 <20101011140039.15a2c78d.akpm@linux-foundation.org>
	 <20101013144044.GS30667@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Oct 2010 07:59:10 +1100
Message-ID: <1287435550.2341.7.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pacman@kosh.dhis.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-10-13 at 15:40 +0100, Mel Gorman wrote:
> 
> This is somewhat contrived but I can see how it might happen even on one
> CPU particularly if the L1 cache is virtual and is loose about checking
> physical tags.
> 
> > How sensitive/vulnerable is PPC32 to such things?
> > 
> 
> I can not tell you specifically but if the above scenario is in any way
> plausible, I believe it would depend on what sort of L1 cache the CPU
> has. Maybe this particular version has a virtual cache with no physical
> tagging and is depending on the OS not to make virtual aliasing mistakes.

Nah, ppc doesn't have problems with cache aliases, it all looks
physically tagged to the programmer (tho there's subtleties but none
that explains the reported behaviour).

Looks like real memory corruption to me.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
