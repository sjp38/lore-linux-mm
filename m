Date: Wed, 25 Apr 2007 08:56:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 10/16] Variable Order Page Cache: Readahead fixups
In-Reply-To: <20070425113613.GF19942@skynet.ie>
Message-ID: <Pine.LNX.4.64.0704250854420.24530@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
 <20070423064937.5458.59638.sendpatchset@schroedinger.engr.sgi.com>
 <20070425113613.GF19942@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Dave Hansen <hansendc@us.ibm.com>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Apr 2007, Mel Gorman wrote:

> > +		/*
> > +		 * FIXME: Note the 2M constant here that may prove to
> > +		 * be a problem if page sizes become bigger than one megabyte.
> > +		 */
> > +		unsigned long this_chunk = page_cache_index(mapping, 2 * 1024 * 1024);
> >
> 
> Should readahead just be disabled when the compound page size is as
> large or larger than what readahead normally reads?

I am not sure how to solve that one yet. With the above fix we stay at the 
2M sized readahead. As the compound order increases so the number of pages
is reduced. We could keep the number of pages constant but then very high
orders may cause a excessive use of memory for readahead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
