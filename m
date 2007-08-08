Date: Wed, 8 Aug 2007 16:37:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple
 zonelists v2
In-Reply-To: <1186612807.5055.106.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708081636130.17335@schroedinger.engr.sgi.com>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0708081025330.12652@schroedinger.engr.sgi.com>
 <1186597819.5055.37.camel@localhost>  <20070808214420.GD2441@skynet.ie>
 <1186612807.5055.106.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@skynet.ie>, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Lee Schermerhorn wrote:

> It'll take me a while to absorb the patch, so I'll just ask:  Where does
> the zonelist for the argument come from?  If the the bind policy
> zonelist is removed, then does it come from a node?  There'll be only

Right.

> one per node with your other patches, right?  So you had to have a node
> id, to look up the zonelist?  Do you need the zonelist elsewhere,
> outside of alloc_pages()?  If not, why not just let alloc_pages look it
> up from a starting node [which I think can be determined from the
> policy]?  
 
Exactly. The starting node is passed to alloc_pages_nodemask. We could 
just pass -1 for numa_node_id().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
