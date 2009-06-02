Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7085F6B00BD
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:21:51 -0400 (EDT)
Date: Tue, 2 Jun 2009 16:21:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602142143.GD26982@wotan.suse.de>
References: <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602125713.GG1392@wotan.suse.de> <20090602132538.GK1065@one.firstfloor.org> <20090602132441.GC6262@wotan.suse.de> <20090602134126.GM1065@one.firstfloor.org> <20090602135324.GB21338@localhost> <20090602140639.GQ1065@one.firstfloor.org> <20090602141222.GD21338@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602141222.GD21338@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 10:12:22PM +0800, Wu Fengguang wrote:
> On Tue, Jun 02, 2009 at 10:06:39PM +0800, Andi Kleen wrote:
> > > > Ok you're right. That one is not needed. I will remove it.
> > > 
> > > No! Please read the comment. In fact __remove_from_page_cache() has a
> > > 
> > >                 BUG_ON(page_mapped(page));
> > > 
> > > Or, at least correct that BUG_ON() line together.
> > 
> > Yes, but we already have them unmapped earlier and the poison check
> 
> But you commented "try_to_unmap can fail temporarily due to races."
> 
> That's self-contradictory.

If you use the bloody code I posted (and suggested from the start),
then you DON'T HAVE TO WORRY ABOUT THIS, because it is handled by
the subsystem that knows about it.

How anybody can say it will make your code overcomplicated or "is
not much improvement" is just totally beyond me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
