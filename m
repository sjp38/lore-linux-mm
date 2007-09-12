Date: Wed, 12 Sep 2007 14:17:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/6] Have zonelist contains structs with both a zone
 pointer and zone_idx
In-Reply-To: <20070912210605.31625.85794.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0709121415350.3130@schroedinger.engr.sgi.com>
References: <20070912210444.31625.65810.sendpatchset@skynet.skynet.ie>
 <20070912210605.31625.85794.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Mel Gorman wrote:

>  /*
> + * This struct contains information about a zone in a zonelist. It is stored
> + * here to avoid dereferences into large structures and lookups of tables
> + */
> +struct zoneref {
> +	struct zone *zone;	/* Pointer to actual zone */
> +	int zone_idx;		/* zone_idx(zoneref->zone) */
> +};


Well the structure is going to be 12 bytes wide. Since pointers have to be 
aligned to 8 bytes we will effectively have to use 16 bytes anyways. There 
is no additional memory use if we would be adding another 4 bytes.

But lets get this merged. We can sort this out later. Too many 
oscillations already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
