Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C8B5C6B007B
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 07:31:27 -0500 (EST)
Date: Tue, 26 Jan 2010 13:30:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
Message-ID: <20100126123037.GE30452@random.random>
References: <patchbomb.1264439931@v2.random>
 <edb236c55565378596ae.1264439932@v2.random>
 <20100126114101.GB16468@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126114101.GB16468@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 11:41:01AM +0000, Mel Gorman wrote:
> On Mon, Jan 25, 2010 at 06:18:52PM +0100, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Define MADV_HUGEPAGE.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> > 
> > diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> > --- a/include/asm-generic/mman-common.h
> > +++ b/include/asm-generic/mman-common.h
> > @@ -45,6 +45,8 @@
> >  #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
> >  #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
> >  
> > +#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
> > +
> 
> The use of 14 collides with parisc
> 
> $ git grep MADV_ | grep define | grep 14
> arch/parisc/include/asm/mman.h:#define MADV_16K_PAGES  14 /* Use 16K pages */

Very error prone that you can register in arch file, there are 4
billions MADV_ available, the arch files shall be removed and it
should all be defined in mman-common.h.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
