Subject: Re: [RFC] 0/4 Migration Cache Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0602211001110.19955@schroedinger.engr.sgi.com>
References: <1140190593.5219.22.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602170816530.30999@schroedinger.engr.sgi.com>
	 <1140195598.5219.77.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602170906030.31408@schroedinger.engr.sgi.com>
	 <43FA8690.3070608@yahoo.com.au> <20060221184016.GA19696@dmt.cnet>
	 <Pine.LNX.4.64.0602211001110.19955@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 21 Feb 2006 13:49:51 -0500
Message-Id: <1140547791.5207.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-02-21 at 10:04 -0800, Christoph Lameter wrote:
> On Tue, 21 Feb 2006, Marcelo Tosatti wrote:
> 
> > The idea was to create a "partition" inside the swapcache which allows
> > for mapping+offset->pfn translation _without_ actually occupying space
> > in the swap map (an idr table is used instead).
> > 
> > But apparently Christoph's mechanism adds the PFN number into
> > the page table entry itself, thus fulfilling the requirement for
> > "mapping+offset"->pfn indexing required for removal of pages underneath
> > a living process. Is that right?
> 
> Right. Swap ptes contain the index into swap space which I am using to 
> preserve the information contained in the pte's of anonymous pages. Thus 
> the existing swap ptes couild be used. There were just a few minor 
> modifications to the swap functions required.
> 

Are the swap ptes used for migrating pages still reserving swap space on
real swap devices?  I thought this was what the migration cache was
trying to avoid.  Now each running instance of direct migration limits
itself to MIGRATE_CHUNK_SIZE [currently] 256 pages, so if the system has
much swap space at all, this shouldn't place too much of a load on swap
space.  But, it does require that one have SOME swap space to migrate,
right?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
