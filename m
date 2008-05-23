Date: Fri, 23 May 2008 07:37:08 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 14/18] hugetlb: printk cleanup
Message-ID: <20080523053708.GN13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.134811000@nick.local0.net> <20080427033242.GA12129@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080427033242.GA12129@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 26, 2008 at 08:32:42PM -0700, Nishanth Aravamudan wrote:
> On 23.04.2008 [11:53:16 +1000], npiggin@suse.de wrote:
> > - Reword sentence to clarify meaning with multiple options
> > - Add support for using GB prefixes for the page size
> > - Add extra printk to delayed > MAX_ORDER allocation code
> > 
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> >  mm/hugetlb.c |   21 +++++++++++++++++----
> >  1 file changed, 17 insertions(+), 4 deletions(-)
> > 
> > Index: linux-2.6/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.orig/mm/hugetlb.c
> > +++ linux-2.6/mm/hugetlb.c
> > @@ -612,15 +612,28 @@ static void __init hugetlb_init_hstates(
> >  	}
> >  }
> > 
> > +static __init char *memfmt(char *buf, unsigned long n)
> 
> Nit: this function is the only one where __init preceds the return type?

Fixed, thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
