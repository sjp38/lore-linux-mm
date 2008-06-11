Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5BKFPDj030812
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 16:15:25 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5BKFJfE133882
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:15:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5BKFI7I019085
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:15:18 -0600
Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1213213980.20045.116.camel@calx>
References: <20080611180228.12987026@kernel>
	 <20080611180230.7459973B@kernel>
	 <20080611123724.3a79ea61.akpm@linux-foundation.org>
	 <1213213980.20045.116.camel@calx>
Content-Type: text/plain
Date: Wed, 11 Jun 2008 13:15:16 -0700
Message-Id: <1213215316.20475.22.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hans.rosenfeld@amd.com, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, "ADAM G. LITKE [imap]" <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-11 at 14:53 -0500, Matt Mackall wrote:
> 
> > I don't get it.   Why can't we just stick a
> > 
> >       if (pmd_huge(pmd))
> >               continue;
> > 
> > into pagemap_pte_range()?  Or something like that.
> 
> That's certainly what you'd hope to be able to do, yes.
> 
> If I recall the earlier discussion, some arches with huge pages can
> only
> identify them via a VMA. Obviously, any arch with hardware that walks
> our pagetables directly must be able to identify huge pages directly
> from those tables, but I think PPC and a couple others that don't have
> hardware TLB fill fail to store such a bit in the tables at all.

Yeah, the ppc (and more) huge pmd entries are just the address of the
huge page.  I would love to get all of them converted so we could use
pmd_huge() on them, eventually.  But, that's a much bigger undertaking.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
