Date: Wed, 25 Apr 2007 08:43:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 02/16] vmstat.c: Support accounting for compound pages
In-Reply-To: <20070425105946.GB19942@skynet.ie>
Message-ID: <Pine.LNX.4.64.0704250840240.24530@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
 <20070423064855.5458.73630.sendpatchset@schroedinger.engr.sgi.com>
 <20070425105946.GB19942@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Dave Hansen <hansendc@us.ibm.com>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Apr 2007, Mel Gorman wrote:

> > This will avoid numerous changes in the VM to fix up page accounting
> > as we add more support for  compound pages.
> > 
> > Also fix up the accounting for active / inactive pages.
> Should this patch be split in two then? The active/inactive looks like
> it's worth doing anyway

We could split it but both pieces are only necessary for higher order 
compound pages on the LRU.

> >  EXPORT_SYMBOL(inc_zone_page_state);
> 
> Everything after here looks like a standalone cleanup.

Its not sorry. __inc_zone_page_state has a bit more overhead than 
__inc_zone_state. Needs to determine the zone again. Maybe we need to 
create a __inc_zone_compound_state or so that does not repeat the zone 
determination.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
