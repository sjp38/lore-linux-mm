Date: Fri, 23 May 2008 07:29:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/18] hugetlbfs: support larger than MAX_ORDER
Message-ID: <20080523052957.GK13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.965631000@nick.local0.net> <20080425185543.GA14623@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425185543.GA14623@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 25, 2008 at 11:55:43AM -0700, Nishanth Aravamudan wrote:
> On 23.04.2008 [11:53:14 +1000], npiggin@suse.de wrote:
> > This is needed on x86-64 to handle GB pages in hugetlbfs, because it is
> > not practical to enlarge MAX_ORDER to 1GB. 
> > 
> >  #include <asm/page.h>
> >  #include <asm/pgtable.h>
> > @@ -160,7 +161,7 @@ static void free_huge_page(struct page *
> >  	INIT_LIST_HEAD(&page->lru);
> > 
> >  	spin_lock(&hugetlb_lock);
> > -	if (h->surplus_huge_pages_node[nid]) {
> > +	if (h->surplus_huge_pages_node[nid] && h->order < MAX_ORDER) {
> 
> Shouldn't all h->order accesses actually be using the huge_page_order()
> to be consistent?

yes, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
