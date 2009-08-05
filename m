Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 110C76B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 10:01:48 -0400 (EDT)
Date: Wed, 5 Aug 2009 16:01:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct truncating of page v2
Message-ID: <20090805140145.GB28563@wotan.suse.de>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de> <20090805134607.GH11385@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805134607.GH11385@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 03:46:08PM +0200, Andi Kleen wrote:
> On Wed, Aug 05, 2009 at 12:20:08PM +0200, Nick Piggin wrote:
> > >  truncate_complete_page(struct address_space *mapping, struct page *page)
> > >  {
> > >  	if (page->mapping != mapping)
> > > -		return;
> > > +		return -EIO;
> > 
> > Hmm, at this point, the page must have been removed from pagecache,
> > so I don't know if you need to pass an error back?
> 
> It could be reused, which would be bad for us?
 
I haven't brought up the caller at this point, but IIRC you had
the page locked and mapping confirmed at this point anyway so
it would never be an error for your code.

Probably it would be nice to just force callers to verify the page.
Normally IMO it is much nicer and clearer to do it at the time the
page gets locked, unless there is good reason otherwise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
