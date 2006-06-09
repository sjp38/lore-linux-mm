Date: Fri, 9 Jun 2006 11:49:50 +0300
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] hugetlb: powerpc: Actively close unused htlb regions on vma close
Message-ID: <20060609084950.GA30625@localhost.localdomain>
References: <1149257287.9693.6.camel@localhost.localdomain> <Pine.LNX.4.64.0606021301300.5492@schroedinger.engr.sgi.com> <1149281841.9693.39.camel@localhost.localdomain> <Pine.LNX.4.64.0606021407580.6179@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0606021407580.6179@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Adam Litke <agl@us.ibm.com>, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 02, 2006 at 02:08:27PM -0700, Christoph Lameter wrote:
> On Fri, 2 Jun 2006, Adam Litke wrote:
> 
> > The real reason I want to "close" hugetlb regions (even on 64bit
> > platforms) is so a process can replace a previous hugetlb mapping with
> > normal pages when huge pages become scarce.  An example would be the
> > hugetlb morecore (malloc) feature in libhugetlbfs :)
> 
> Well that approach wont work on IA64 it seems.

Yes, but there's not much that can be done about that.

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
