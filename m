Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AA84B6B01EE
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 10:14:18 -0400 (EDT)
Date: Wed, 21 Apr 2010 09:13:30 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
In-Reply-To: <w2ucf18f8341004191908v2546cfffo3cc7615802ca1c80@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004210909110.4959@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>  <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>  <20100413083855.GS25756@csn.ul.ie>  <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>  <20100416111539.GC19264@csn.ul.ie>
  <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>  <alpine.DEB.2.00.1004161049130.7710@router.home>  <m2vcf18f8341004170654tc743e4b0s73a0e234cfdcda93@mail.gmail.com>  <alpine.DEB.2.00.1004191245250.9855@router.home>
 <w2ucf18f8341004191908v2546cfffo3cc7615802ca1c80@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 20 Apr 2010, Bob Liu wrote:

> On Tue, Apr 20, 2010 at 1:47 AM, Christoph Lameter
> <cl@linux-foundation.org> wrote:
> > On Sat, 17 Apr 2010, Bob Liu wrote:
> >
> >> > GFP_THISNODE forces allocation from the node. Without it we will fallback.
> >> >
> >>
> >> Yeah, but I think we shouldn't fallback at this case, what we want is
> >> alloc a page
> >> from exactly the dest node during migrate_to_node(dest).So I added
> >> GFP_THISNODE.
> >
> > Why would we want that?
> >
>
> Because if dest node have no memory, it will fallback to other nodes.
> The dest node's fallback nodes may be nodes in nodemask from_nodes.
> It maybe make circulation ?.(I am not sure.)
>
> What's more,i think it against the user's request.

The problem is your perception of NUMA against the kernel NUMA design. As
long as you have this problem I would suggest that you do not submit
patches against NUMA functionality in the kernel.

> The user wants to move pages from from_nodes to to_nodes, if fallback
> happened, the pages may be moved to other nodes instead of any node in
> nodemask to_nodes.
> I am not sure if the user can expect this and accept.

Sure the user always had it this way. NUMA allocations (like also
MPOL_INTERLEAVE round robin) are *only* attempts to allocate on specific
nodes.

There was never a guarantee (until GFP_THISNODE arrived on the scene to
fix SLAB breakage but that was very late in NUMA design of the kernel).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
