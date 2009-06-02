Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2CFC46B00AB
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:12:46 -0400 (EDT)
Date: Tue, 2 Jun 2009 22:12:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090602141222.GD21338@localhost>
References: <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602125713.GG1392@wotan.suse.de> <20090602132538.GK1065@one.firstfloor.org> <20090602132441.GC6262@wotan.suse.de> <20090602134126.GM1065@one.firstfloor.org> <20090602135324.GB21338@localhost> <20090602140639.GQ1065@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602140639.GQ1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 10:06:39PM +0800, Andi Kleen wrote:
> > > Ok you're right. That one is not needed. I will remove it.
> > 
> > No! Please read the comment. In fact __remove_from_page_cache() has a
> > 
> >                 BUG_ON(page_mapped(page));
> > 
> > Or, at least correct that BUG_ON() line together.
> 
> Yes, but we already have them unmapped earlier and the poison check

But you commented "try_to_unmap can fail temporarily due to races."

That's self-contradictory.

> in the page fault handler should prevent remapping.
> 
> So it really should not happen and if it happened we would deserve
> the BUG.
> 
> -Andi
> 
> -- 
> ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
