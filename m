Date: Tue, 24 Jul 2007 10:28:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] zone config patch set [2/2] CONFIG_ZONE_MOVABLE
Message-Id: <20070724102842.bf470561.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070723134517.GA15510@skynet.ie>
References: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20070721160336.28ec3ad8.kamezawa.hiroyu@jp.fujitsu.com>
	<20070723134517.GA15510@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "apw@shadowen.org" <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007 14:45:17 +0100
mel@skynet.ie (Mel Gorman) wrote:

> > -	return 0;
> > +	return is_configured_zone(ZONE_HIGHMEM) &&
> > +	       is_configured_zone(ZONE_MOVABLE) &&
> > +		(movable_zone == ZONE_HIGHMEM);
> >  }
> 
> I think this should remain inside the check for
> CONFIG_ARCH_POPULATES_NODE_MAP . movable_zone is not defined if it is
> not set. While this works with a cross-compiler for ARM (doesn't use
> CONFIG_ARCH_POPULATES_NODE_MAP), it's because the optimiser is getting
> rid of the references as opposed to the code being correct.

Hmm, ok.


> > +
> > +config ZONE_MOVABLE
> > +	bool	"A zone for movable pages"
> > +	depends on ARCH_POPULATES_NODE_MAP
> > +	help
> > +	  Allows creating a zone type only for movable pages, i.e page cache
> 
> e.g. instead of i.e. here
> 
> i.e. implies that only page cache and anonymous memory can use the zone.
> e.g. implies that page cache and anonymous memory are just two types
> that can use it.
> 

> > +	  and anonymous memory. Because movable pages are to end to be easily
> 
> Because movable pages are easily reclaimed .....
> 
> > +	  reclaimed and page migration technique can move them, your chance
> > +	  for allocating big size memory will be better in this zone than
> 
> allocating contiguous memory such as huge pages will be better ....
> 

thanks, I'll merge above comments.


> > +	if (!is_configured_zone(ZONE_MOVABLE)) {
> > +		printk ("ZONE_MOVABLE is not configured, kernelcore= is ignored.\n");
> > +		return 0;
> > +	}
> 
> This is a good check but bear in mind that in 2.6.23-rc1, this block of
> code looks different and there is both cmdline_parse_kernelcore() and
> cmdline_parse_movablecore().
> 
yes. ok. I'll rebase.

Thank you.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
