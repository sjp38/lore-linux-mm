Date: Wed, 11 Jun 2008 05:18:22 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
Message-ID: <20080611031822.GA8228@wotan.suse.de>
References: <20080605094300.295184000@nick.local0.net> <20080605094826.128415000@nick.local0.net> <Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 10, 2008 at 12:00:48PM -0700, Christoph Lameter wrote:
> On Thu, 5 Jun 2008, npiggin@suse.de wrote:
> 
> > Index: linux-2.6/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm.h
> > +++ linux-2.6/include/linux/mm.h
> > @@ -244,7 +244,7 @@ static inline int put_page_testzero(stru
> >   */
> >  static inline int get_page_unless_zero(struct page *page)
> >  {
> > -	VM_BUG_ON(PageTail(page));
> > +	VM_BUG_ON(PageCompound(page));
> >  	return atomic_inc_not_zero(&page->_count);
> >  }
> 
> This is reversing the modification to make get_page_unless_zero() usable 
> with compound page heads. Will break the slab defrag patchset.

Is the slab defrag patchset in -mm? Because you ignored my comment about
this change that assertions should not be weakened until required by the
actual patchset. I wanted to have these assertions be as strong as
possible for the lockless pagecache patchset.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
