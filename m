Received: from midway.site ([71.117.236.95]) by xenotime.net for <linux-mm@kvack.org>; Wed, 4 Oct 2006 08:13:28 -0700
Date: Wed, 4 Oct 2006 08:14:54 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH v2] page_alloc: fix kernel-doc and func. declaration
Message-Id: <20061004081454.60ab4a66.rdunlap@xenotime.net>
In-Reply-To: <Pine.LNX.4.64.0610041115270.21730@skynet.skynet.ie>
References: <20061003141445.0c502d45.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0610031435590.22775@schroedinger.engr.sgi.com>
	<20061003154949.7953c6f9.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0610031605300.23654@schroedinger.engr.sgi.com>
	<20061003161725.05155ce2.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0610041115270.21730@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Oct 2006 11:26:31 +0100 (IST) Mel Gorman wrote:

> On Tue, 3 Oct 2006, Randy Dunlap wrote:
> 
> > /**
> >  * free_bootmem_with_active_regions - Call free_bootmem_node for each active range
> > - * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed
> > - * @max_low_pfn: The highest PFN that till be passed to free_bootmem_node
> > + * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed.
> > + * @max_low_pfn: The highest PFN that will be passed to free_bootmem_node
> 
> Should @max_low_pfn have a '.' at the end?

I didn't add one since it's not a complete sentence.

> >  *
> >  * If an architecture guarantees that all ranges registered with
> >  * add_active_ranges() contain no holes and may be freed, this
> > @@ -2582,11 +2582,12 @@ void __init shrink_active_range(unsigned
> >
> > /**
> >  * remove_all_active_ranges - Remove all currently registered regions
> > + *
> 
> For future reference, I am going to assume the newline is required between 
> the arguement list and the long description.

Yes, thanks.

> >  * During discovery, it may be found that a table like SRAT is invalid
> >  * and an alternative discovery method must be used. This function removes
> >  * all currently registered regions.
> >  */

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
