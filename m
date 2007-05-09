Date: Wed, 9 May 2007 13:54:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
In-Reply-To: <1178743039.5047.85.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705091353390.30265@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten>  <1178310543.5236.43.camel@localhost>
  <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
 <1178728661.5047.64.camel@localhost>  <29495f1d0705091259t2532358ana4defb7c4e2a7560@mail.gmail.com>
 <1178743039.5047.85.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Lee Schermerhorn wrote:

> > 
> > > +                       page = alloc_pages_node(nid,
> > > +                                       GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
> > > +                                       HUGETLB_PAGE_ORDER);
> > 
> > Are we taking out the GFP_NOWARN for a reason? I noticed this in
> > Anton's patch, but forgot to ask.
> 
> Actually, I hadn't noticed, but a quick look shows that GFP_THISNODE
> contains the __GFP_NOWARN flag, as well as '_NORETRY which I think is
> OK/desirable.

It is required because GFP_THISNODE needs to fail if it cannot get memory 
from the right node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
