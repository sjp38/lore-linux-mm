Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705090956050.28244@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <Pine.LNX.4.64.0705090956050.28244@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 09 May 2007 15:17:25 -0400
Message-Id: <1178738245.5047.67.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-09 at 09:57 -0700, Christoph Lameter wrote:
> On Wed, 9 May 2007, Lee Schermerhorn wrote:
> 
> > +  					HUGETLB_PAGE_ORDER);
> > +
> > +		nid = next_node(nid, node_online_map);
> > +		if (nid == MAX_NUMNODES)
> > +			nid = first_node(node_online_map);
> 
> Maybe use nr_node_ids here? May save some scanning over online maps?

Good idea.  I won't get to it until next week.  Maybe we'll have more
comments by then.

Anton:  anything to add?  

> 
> >   * int node_possible(node)		Is some node possible?
> > + * int node_populated(node)		Is some node populated [at 'HIGHUSER]
> >   *
> 
> Good.

Thanks.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
