Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BF6416B0055
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 01:13:44 -0400 (EDT)
Date: Thu, 4 Jun 2009 07:20:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [12/16] Refactor truncate to allow direct truncating of page
Message-ID: <20090604052056.GO1065@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184646.B915B1D0292@basil.firstfloor.org> <20090604043208.GB15682@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604043208.GB15682@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "npiggin@suse.de" <npiggin@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 12:32:08PM +0800, Wu Fengguang wrote:
> > +void truncate_inode_page(struct address_space *mapping, struct page *page)
> > +{
> > +	if (page_mapped(page)) {
> > +		unmap_mapping_range(mapping,
> > +		  (loff_t)page->index<<PAGE_CACHE_SHIFT,
> > +		  PAGE_CACHE_SIZE, 0);
> > +	}
> > +	truncate_complete_page(mapping, page);
> > +}
> > +
> 
> Small style cleanup:

Applied.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
