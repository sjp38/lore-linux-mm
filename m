Date: Fri, 23 May 2008 07:30:22 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/18] hugetlbfs: support larger than MAX_ORDER
Message-ID: <20080523053022.GL13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.965631000@nick.local0.net> <1209589263.4461.35.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1209589263.4461.35.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 02:01:03PM -0700, Dave Hansen wrote:
> On Wed, 2008-04-23 at 11:53 +1000, npiggin@suse.de wrote:
> > +static int __init alloc_bm_huge_page(struct hstate *h)
> 
> I was just reading one of Jon's patches, and saw this.  Could we expand
> the '_bm_' to '_boot_'?  Or, maybe rename to bootmem_alloc_hpage()?
> 'bm' just doesn't seem to register in my teeny brain.

OK, I agree. They aren't called too often, so I've changed all bm
to bootmem there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
