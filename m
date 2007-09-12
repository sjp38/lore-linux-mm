Date: Wed, 12 Sep 2007 14:23:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
In-Reply-To: <20070912210625.31625.36220.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0709121420010.3130@schroedinger.engr.sgi.com>
References: <20070912210444.31625.65810.sendpatchset@skynet.skynet.ie>
 <20070912210625.31625.36220.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Mel Gorman wrote:

> -			z++)
> -		;
> +	if (likely(nodes == NULL))
> +		for (; zonelist_zone_idx(z) > highest_zoneidx;
> +				z++)
> +			;
> +	else
> +		for (; zonelist_zone_idx(z) > highest_zoneidx ||
> +				(z->zone && !zref_in_nodemask(z, nodes));
> +				z++)
> +			;
>  

Minor nitpick here: "for (;" should become "for ( ;" to have correct 
whitespace. However, it would be clearer to use a while here.

while (zonelist_zone_idx(z)) > highest_zoneidx)
		z++;

etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
