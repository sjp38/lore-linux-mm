Date: Tue, 16 Oct 2007 20:22:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/6] Have zonelist contains structs with both a zone
 pointer and zone_idx
In-Reply-To: <20070928142446.16783.9970.sendpatchset@skynet.skynet.ie>
Message-ID: <alpine.DEB.0.9999.0710162022220.2326@chino.kir.corp.google.com>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie> <20070928142446.16783.9970.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Sep 2007, Mel Gorman wrote:

> 
> Filtering zonelists requires very frequent use of zone_idx(). This is costly
> as it involves a lookup of another structure and a substraction operation. As
> the zone_idx is often required, it should be quickly accessible.  The node
> idx could also be stored here if it was found that accessing zone->node is
> significant which may be the case on workloads where nodemasks are heavily
> used.
> 
> This patch introduces a struct zoneref to store a zone pointer and a zone
> index.  The zonelist then consists of an array of this struct zonerefs which
> are looked up as necessary. Helpers are given for accessing the zone index
> as well as the node index.
> 
> [kamezawa.hiroyu@jp.fujitsu.com: Suggested struct zoneref instead of embedding information in pointers]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Christoph Lameter <clameter@sgi.com>

OOM locking looks good, thanks.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
