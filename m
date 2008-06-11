Date: Wed, 11 Jun 2008 05:19:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/7] mm: speculative page references
Message-ID: <20080611031926.GB8228@wotan.suse.de>
References: <20080605094300.295184000@nick.local0.net> <20080605094825.699347000@nick.local0.net> <Pine.LNX.4.64.0806101205480.17798@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806101205480.17798@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 10, 2008 at 12:08:27PM -0700, Christoph Lameter wrote:
> On Thu, 5 Jun 2008, npiggin@suse.de wrote:
> 
> > +		 * do the right thing (see comments above).
> > +		 */
> > +		return 0;
> > +	}
> > +#endif
> > +	VM_BUG_ON(PageCompound(page) && (struct page *)page_private(page) != page);
> 
> This is easier written as:
> 
> == VM_BUG_ON(PageTail(page)
 
Yeah that would be nicer.


> And its also slightly incorrect since page_private(page) is not pointing 
> to the head page for PageHead(page).

I see. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
