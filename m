Date: Tue, 12 Sep 2006 10:41:07 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [RFC] Could we get rid of zone_table?
In-Reply-To: <1158081512.9141.10.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0609121037420.11278@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609111714320.7466@schroedinger.engr.sgi.com>
 <1158081512.9141.10.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Sep 2006, Dave Hansen wrote:

> On Mon, 2006-09-11 at 17:17 -0700, Christoph Lameter wrote:
> > I think the only case where we cannot encode the node number
> > are the early 32 bit NUMA systems? In that case one would only
> > need an array that maps the sections to the corresponding pgdat
> > structure and would then get to the zone from there. Dave, could
> > you add something like that to sparse.c? 
> 
> It can certainly be done.  However, I'd rather keep it out of the actual
> struct mem_section, mostly because anything we do will be for a
> relatively rare, and relatively obsolete set of platforms.  

There will be no zone table for UP and SMP. In !NUMA case NODE_DATA(0) 
points to the pgdat with an exact replica of zone_table in the node_zones
field.

> Any new structure (or any mem_section additions) will just shift the
> exact same work that we're doing today with zone_table[] somewhere else.
> The impact into page_alloc.c is also pretty minimal.  It is a single
> #ifdef, over a structure and a single function, right?

The problem is that zone_table seems to be useless except for 
a very rare breed of early 32 bit IBM NUMA machines. Should not be in 
page_alloc.c as far as I can tell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
