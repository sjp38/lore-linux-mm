Date: Fri, 11 Apr 2008 10:59:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 11/17] hugetlbfs: support larger than MAX_ORDER
Message-ID: <20080411085928.GC20253@wotan.suse.de>
References: <20080410170232.015351000@nick.local0.net> <20080410171101.551336000@nick.local0.net> <20080411081317.GQ10019@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411081317.GQ10019@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 11, 2008 at 10:13:17AM +0200, Andi Kleen wrote:
> >  	spin_lock(&hugetlb_lock);
> > -	if (h->surplus_huge_pages_node[nid]) {
> > +	if (h->surplus_huge_pages_node[nid] && h->order <= MAX_ORDER) {
> 
> As Andrew Hastings pointed out earlier this all needs to be h->order < MAX_ORDER
> [got pretty much all the checks wrong off by one]. It won't affect anything
> on x86-64 but might cause problems on archs which have exactly MAX_ORDER
> sized huge pages.

Ah, hmm, I might have missed a couple of emails worth of feedback when
you last posted. Thanks for pointing this out, I'll read over them again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
