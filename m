Subject: Re: [PATCH 3/3 htlb-acct] Demand faulting for huge pages
References: <1127939141.26401.32.camel@localhost.localdomain>
	<1127939593.26401.38.camel@localhost.localdomain>
	<20050928232027.28e1bb93.akpm@osdl.org>
From: Andi Kleen <ak@suse.de>
Date: 29 Sep 2005 11:45:12 +0200
In-Reply-To: <20050928232027.28e1bb93.akpm@osdl.org>
Message-ID: <p73k6h0jjh3.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: agl@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> writes:

(having written the original SLES9 code I will chime in ...) 

> > +unsigned long
> > +huge_pages_needed(struct address_space *mapping, struct vm_area_struct *vma)
> > +{
> 
> What does this function do?  Seems to count all the present pages within a
> vma which are backed by a particular hugetlbfs file?  Or something?

It counts how many huge pages are still needed to fill up a mapping completely.
In short it counts the holes. I think the name fits.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
