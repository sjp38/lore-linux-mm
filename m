Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 848D06B0055
	for <linux-mm@kvack.org>; Thu, 28 May 2009 09:41:32 -0400 (EDT)
Date: Thu, 28 May 2009 15:48:48 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090528134848.GI1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528101111.GE1065@one.firstfloor.org> <20090528103300.GA15133@localhost> <20090528105103.GG1065@one.firstfloor.org> <20090528121541.GL6920@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528121541.GL6920@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 02:15:41PM +0200, Nick Piggin wrote:
> For correctness for what? You can't remove a page from swapcache or
> pagecache under writeback because then the mm thinks that location
> is not being used.

I'm adding wait_on_page_writeback() to memory_failure(), so 
it will be out of the picture hopefully

> 
>  
> > I'm mainly interested in correctness (as in not crashing) of this
> > version now.
> > 
> > Also writeback seems to be only used by nfs/afs/nilfs2, not in
> > the normal case, unless I'm misreading the code. 
> 
> I don't follow. What writeback are you talking about?

Sorry I misread the code, it's indeed used more commonly.


> > > Then the writeback pages simply won't reach here. And it won't
> > > magically go into writeback state, since the page has been locked.
> > 
> > But since we take the page lock they should not be in writeback anyways,
> > no?
> 
> No. PG_writeback was introduced so as to reduce page lock hold
> times (most of writeback runs without page lock held).

Ok. Then the wait_on_page_writeback() will take care of that.

Thanks for the feedback,

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
