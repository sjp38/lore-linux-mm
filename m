Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
	hotplug
From: Nigel Cunningham <ncunningham@crca.org.au>
In-Reply-To: <1225751665.12673.511.camel@nimitz>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <20081103125108.46d0639e.akpm@linux-foundation.org>
	 <1225747308.12673.486.camel@nimitz>  <200811032324.02163.rjw@sisk.pl>
	 <1225751665.12673.511.camel@nimitz>
Content-Type: text/plain
Date: Tue, 04 Nov 2008 15:02:33 +1100
Message-Id: <1225771353.6755.16.camel@nigel-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Mon, 2008-11-03 at 14:34 -0800, Dave Hansen wrote:
> A node might have a node_start_pfn=0 and a node_end_pfn=100 (and it may
> have only one zone).  But, there may be another node with
> node_start_pfn=10 and a node_end_pfn=20.  This loop:
> 
>         for_each_zone(zone) {
> 		...
>                 for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
>                         if (page_is_saveable(zone, pfn))
>                                 memory_bm_set_bit(orig_bm, pfn);
>         }
> 
> will walk over the smaller node's pfn range multiple times.  Is this OK?
> 
> I think all you have to do to fix it is check page_zone(page) == zone
> and skip out if they don't match.

So pfn 10 in the first node refers to the same memory as pfn 10 in the
second node?

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
