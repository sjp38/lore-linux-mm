Date: Fri, 23 May 2008 07:19:24 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080523051924.GE13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net> <20080429172734.GE24967@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429172734.GE24967@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 10:27:34AM -0700, Nishanth Aravamudan wrote:
> On 23.04.2008 [11:53:07 +1000], npiggin@suse.de wrote:
> > Add basic support for more than one hstate in hugetlbfs
> > 
> > - Convert hstates to an array
> > - Add a first default entry covering the standard huge page size
> > - Add functions for architectures to register new hstates
> > - Add basic iterators over hstates
> > 
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> >  include/linux/hugetlb.h |   11 ++++
> >  mm/hugetlb.c            |  112 +++++++++++++++++++++++++++++++++++++-----------
> >  2 files changed, 97 insertions(+), 26 deletions(-)
> > 
> > Index: linux-2.6/mm/hugetlb.c
> > ===================================================================
> 
> <snip>
> 
> > +/* Should be called on processing a hugepagesz=... option */
> > +void __init huge_add_hstate(unsigned order)
> 
> For consistency's sake, can we call this hugetlb_add_hstate()?

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
