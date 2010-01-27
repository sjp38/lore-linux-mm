Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6DB646B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:01:03 -0500 (EST)
Date: Wed, 27 Jan 2010 20:59:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13 of 31] add pmd mangling functions to x86
Message-ID: <20100127195957.GC13766@random.random>
References: <patchbomb.1264513915@v2.random>
 <3bd66d70a20aa0f0f48a.1264513928@v2.random>
 <20100126194059.GR16468@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126194059.GR16468@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 07:41:00PM +0000, Mel Gorman wrote:
> On Tue, Jan 26, 2010 at 02:52:08PM +0100, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Add needed pmd mangling functions with simmetry with their pte counterparts.
> > pmdp_freeze_flush is the only exception only present on the pmd side and it's
> > needed to serialize the VM against split_huge_page, it simply atomically clears
> > the present bit in the same way pmdp_clear_flush_young atomically clears the
> > accessed bit (and both need to flush the tlb to make it effective, which is
> > mandatory to happen synchronously for pmdp_freeze_flush).
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Does pmdp_splitting_flush() belong in this set? I don't think
> _PAGE_BIT_SPLITTING has been defined yet for example. Other than that,
> it looked ok.

It is set in pmd_trans:

pmd_mangling_x86
pmd_mangling_generic
pmd_trans

I'll reverse the order to:

pmd_trans
pmd_mangling_x86
pmd_mangling_generic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
