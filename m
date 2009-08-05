Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E75116B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 09:46:05 -0400 (EDT)
Date: Wed, 5 Aug 2009 15:46:08 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [11/19] HWPOISON: Refactor truncate to allow direct
	truncating of page v2
Message-ID: <20090805134607.GH11385@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093638.D3754B15D8@basil.firstfloor.org> <20090805102008.GB17190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805102008.GB17190@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 12:20:08PM +0200, Nick Piggin wrote:
> >  truncate_complete_page(struct address_space *mapping, struct page *page)
> >  {
> >  	if (page->mapping != mapping)
> > -		return;
> > +		return -EIO;
> 
> Hmm, at this point, the page must have been removed from pagecache,
> so I don't know if you need to pass an error back?

It could be reused, which would be bad for us?

The final check is the page error count in the end anyways.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
