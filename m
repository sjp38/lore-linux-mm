Date: Wed, 13 Sep 2006 15:02:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table
In-Reply-To: <1158184735.9141.167.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0609131459470.20028@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
 <1158180795.9141.158.camel@localhost.localdomain>
 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
 <1158184047.9141.164.camel@localhost.localdomain>
 <Pine.LNX.4.64.0609131452330.19506@schroedinger.engr.sgi.com>
 <1158184735.9141.167.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Dave Hansen wrote:

> > Sorry I am a bit new to sparsemem but it seems that the mem sections are 
> > arrays of pointers. You would like to store the node number in the lower 
> > unused bits?
> 
> I thought this patch was only for 32-bit NUMA platforms that have run
> out of bits in page->flags to encode the data.  Does it apply to ia64 as
> well somehow?

Yes, the section_to_node_table is only for 32 bit NUMA platforms that ran 
out of bits. Aha. Then you can work within the restrictions of that 
environment and you do not have to be general.

If you only need 4 bits then you could take those from the first two 
pointers of a memsection and maybe you could find them elsewhere.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
