Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6438D6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 22:45:17 -0500 (EST)
Date: Wed, 4 Nov 2009 14:22:42 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: Filtering bits in set_pte_at()
Message-ID: <20091104032242.GC27772@yookeroo.seuss>
References: <1256957081.6372.344.camel@pasglop>
 <Pine.LNX.4.64.0911021256330.32400@sister.anvils>
 <1257200367.7907.50.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1257200367.7907.50.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 03, 2009 at 09:19:27AM +1100, Benjamin Herrenschmidt wrote:
> On Mon, 2009-11-02 at 13:27 +0000, Hugh Dickins wrote:
> > On Sat, 31 Oct 2009, Benjamin Herrenschmidt wrote:
> > 
> > > Hi folks !
> > > 
> > > So I have a little problem on powerpc ... :-)
> > 
> > Thanks a lot for running this by us.
> 
> Heh, I though you may have been bored :-)
> 
> > I've not looked to see if there are more such issues in arch/powerpc
> > itself, but those instances you mention are the only ones I managed
> > to find: uses of update_mmu_cache() and that hugetlb_cow() one.
> 
> Right, that's all I spotted so far
> 
> > The hugetlb_cow() one involves not set_pte_at() but set_huge_pte_at(),
> > so you'd want to change that too?  And presumably set_pte_at_notify()?
> > It all seems a lot of tedium, when so very few places are interested
> > in the pte after they've set it.
> 
> We need to change set_huge_pte_at() too. Currently, David fixed the
> problem in a local tree by making hugetlb_cow() re-read the PTE . 

Well, actually I have another cleanup patch in the queue which makes
set_huge_pte_at() equal to set_pte_at() on powerpc, and I was using
that on the tree where this problem became apparent.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
