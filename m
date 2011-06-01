Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 629D46B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 14:19:44 -0400 (EDT)
Date: Wed, 1 Jun 2011 19:19:18 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
	instead of failing
Message-ID: <20110601181918.GO3660@n2100.arm.linux.org.uk>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com> <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jun 01, 2011 at 10:23:15AM -0700, David Rientjes wrote:
> On Wed, 1 Jun 2011, Dmitry Eremin-Solenikov wrote:
> 
> > I've hit this with IrDA driver on PXA. Also I've seen the report regarding
> > other ARM platform (ep-something). Thus I've included Russell in the cc.
> > 
> 
> So you want to continue to allow the page allocator to return pages from 
> anywhere, even when GFP_DMA is specified, just as though it was lowmem?

No.  What *everyone* is asking for is to allow the situation which has
persisted thus far to continue for ONE MORE RELEASE but with a WARNING
so that these problems can be found without causing REGRESSIONS.

That is NOT an unreasonable request, but it seems that its far too much
to ask of you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
