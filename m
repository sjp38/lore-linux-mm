Date: Wed, 10 Oct 2007 21:14:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] hugetlb: fix hugepage allocation with memoryless nodes
In-Reply-To: <20071011041119.GB32657@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0710102112470.28507@schroedinger.engr.sgi.com>
References: <20071009012724.GA26472@us.ibm.com> <20071011041119.GB32657@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: anton@samba.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, mel@csn.ul.ie, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Oct 2007, Nishanth Aravamudan wrote:

> > +++ b/mm/hugetlb.c
> > @@ -32,6 +32,7 @@ static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> >  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
> >  unsigned long hugepages_treat_as_movable;
> >  int hugetlb_dynamic_pool;
> > +static int last_allocated_nid;
> 
> While reworking patch 2/2 to incorporate the current state of hugetlb.c
> after Adam's stack is applied, I realized that this is not a very good
> name. It actually is the *current* nid to try to allocate hugepages on.
> 
> Christoph, since you proposed the name, do you think
> 
> hugetlb_current_nid
> 
> is ok, too? If so I'll change the name throughout the patch (no
> functional change).

Sure. However, current is bit ambiguous. Is it the node we used last 
or the one to use next? Call it next_hugetlb_nid? Either way is fine with 
me though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
