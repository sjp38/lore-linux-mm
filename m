Date: Thu, 13 Sep 2007 11:25:31 +0100
Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
Message-ID: <20070913102531.GF22778@skynet.ie>
References: <20070912210444.31625.65810.sendpatchset@skynet.skynet.ie> <20070912210625.31625.36220.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0709121420010.3130@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709121420010.3130@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (12/09/07 14:23), Christoph Lameter didst pronounce:
> On Wed, 12 Sep 2007, Mel Gorman wrote:
> 
> > -			z++)
> > -		;
> > +	if (likely(nodes == NULL))
> > +		for (; zonelist_zone_idx(z) > highest_zoneidx;
> > +				z++)
> > +			;
> > +	else
> > +		for (; zonelist_zone_idx(z) > highest_zoneidx ||
> > +				(z->zone && !zref_in_nodemask(z, nodes));
> > +				z++)
> > +			;
> >  
> 
> Minor nitpick here: "for (;" should become "for ( ;" to have correct 
> whitespace. However, it would be clearer to use a while here.
> 
> while (zonelist_zone_idx(z)) > highest_zoneidx)
> 		z++;
> 
> etc.

Good point. I'll clean it up and retest. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
