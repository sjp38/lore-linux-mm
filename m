Date: Fri, 17 Aug 2007 13:59:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/6] Use one zonelist that is filtered instead of multiple
 zonelists
In-Reply-To: <20070817201728.14792.42873.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708171355580.9635@schroedinger.engr.sgi.com>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
 <20070817201728.14792.42873.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Aug 2007, Mel Gorman wrote:

> +/* Returns the first zone at or below highest_zoneidx in a zonelist */
> +static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
> +					enum zone_type highest_zoneidx)
> +{
> +	struct zone **z;
> +	for (z = zonelist->zones; zone_idx(*z) > highest_zoneidx; z++);
> +	return z;
> +}

The formatting above is a bit confusing. Add requires empty lines and put 
the ; on a separate line.


> +/* Returns the next zone at or below highest_zoneidx in a zonelist */
> +static inline struct zone **next_zones_zonelist(struct zone **z,
> +					enum zone_type highest_zoneidx)
> +{
> +	for (++z; zone_idx(*z) > highest_zoneidx; z++);

Looks weird too.

++z on an earlier line and then

	for ( ; zone_idx(*z) ...)

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
