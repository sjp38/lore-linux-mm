Date: Wed, 9 May 2007 09:57:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
In-Reply-To: <1178728661.5047.64.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705090956050.28244@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten>  <1178310543.5236.43.camel@localhost>
  <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
 <1178728661.5047.64.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Lee Schermerhorn wrote:

> +  					HUGETLB_PAGE_ORDER);
> +
> +		nid = next_node(nid, node_online_map);
> +		if (nid == MAX_NUMNODES)
> +			nid = first_node(node_online_map);

Maybe use nr_node_ids here? May save some scanning over online maps?

>   * int node_possible(node)		Is some node possible?
> + * int node_populated(node)		Is some node populated [at 'HIGHUSER]
>   *

Good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
