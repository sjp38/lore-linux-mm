Date: Fri, 29 Feb 2008 11:30:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/6] Remember what the preferred zone is for
 zone_statistics
Message-Id: <20080229113016.346f9cc5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080227214728.6858.79000.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	<20080227214728.6858.79000.sendpatchset@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008 16:47:28 -0500
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> From: Mel Gorman <mel@csn.ul.ie>
> [PATCH 3/6] Remember what the preferred zone is for zone_statistics
> 
> V11r3 against 2.6.25-rc2-mm1
> 
> On NUMA, zone_statistics() is used to record events like numa hit, miss
> and foreign. It assumes that the first zone in a zonelist is the preferred
> zone. When multiple zonelists are replaced by one that is filtered, this
> is no longer the case.
> 
> This patch records what the preferred zone is rather than assuming the
> first zone in the zonelist is it. This simplifies the reading of later
> patches in this set.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 

I have no objection to the direction but


> +static struct page *buffered_rmqueue(struct zone *preferred_zone,
>  			struct zone *zone, int order, gfp_t gfp_flags)
>  {

Can't this be written like this ?

struct page *
buffered_rmqueue(struct zone *zone, int order, gfp_t gfp_flags, bool numa_hit)

Can't caller itself  set this bool value ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
