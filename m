Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 224016B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 20:22:36 -0500 (EST)
Subject: Re: Filtering bits in set_pte_at()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0911022342070.30581@sister.anvils>
References: <1256957081.6372.344.camel@pasglop>
	 <Pine.LNX.4.64.0911021256330.32400@sister.anvils>
	 <1257200367.7907.50.camel@pasglop>
	 <Pine.LNX.4.64.0911022342070.30581@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 Nov 2009 12:22:26 +1100
Message-ID: <1257211346.7907.60.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-02 at 23:45 +0000, Hugh Dickins wrote:
> > IE. update_mmu_cache() would be more generally useful if it took the
> > ptep instead of the pte. Of course, I'm sure some embedded archs are
> > going to cry for the added load here ... 
> > 
> > I like your idea. I'll look into doing a patch converting it and
> will
> > post it here.
> 
> Well, I wasn't proposing
> 
>                 update_mmu_cache(vma, address, ptep);
> but
>                 update_mmu_cache(vma, address, *ptep);
> 
> which may not meet your future idea, but is much less churn for now
> i.e. no change to any of the arch's update_mmu_cache(),
> just a change to some of its callsites. 

I see... but if we go that way, I think we may as well do the whole
churn... I'll have a look at how bad it is.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
