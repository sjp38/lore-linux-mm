Date: Tue, 14 Aug 2007 12:33:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Minor [?] page migration bug in check_pte_range()
In-Reply-To: <1187105148.6281.38.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708141231210.30435@schroedinger.engr.sgi.com>
References: <1187105148.6281.38.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Lee Schermerhorn wrote:

> What I see is that when you attempt to install an interleave policy and
> migrate the pages to match that policy, any pages on nodes included in
> the interleave node mask will not be migrated to match policy.  This

Right. The pages are already on permitted nodes.

> occurs because of the clever, but overly simplistic test in
> check_pte_range():
> 
> 	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
> 		continue;
> 
> Fixing this would, I think, involve checking each page against the
> location dictated by the new policy.  Altho' I don't think this is a
> performance critical path, it is the inner-most loop of check_range().
> 
> Is this worth addressing, do you think?

This is not going to be easy because you would have to move each 
individual pages to a particular node. Or setup lists for each node and 
then do several calls to migrate page.

I think we can leave it as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
