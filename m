Date: Fri, 29 Feb 2008 14:19:25 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] Remember what the preferred zone is for zone_statistics
Message-ID: <20080229141924.GB6045@csn.ul.ie>
References: <20080227214708.6858.53458.sendpatchset@localhost> <20080227214728.6858.79000.sendpatchset@localhost> <Pine.LNX.4.64.0802271400110.12963@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802271400110.12963@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, akpm@linux-foundation.org, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (27/02/08 14:00), Christoph Lameter didst pronounce:
> > This patch records what the preferred zone is rather than assuming the
> > first zone in the zonelist is it. This simplifies the reading of later
> > patches in this set.
> 
> And is needed for correctness if GFP_THISNODE is used?
> 

Yes, I should have noted that. Without the patch, statistics could be updated
in the wrong place.

> Reviewed-by: Christoph Lameter <clameter@sgi.com>
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
