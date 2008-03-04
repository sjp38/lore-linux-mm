Date: Tue, 4 Mar 2008 12:02:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
In-Reply-To: <Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0803041201510.18277@schroedinger.engr.sgi.com>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>
 <47CD4AB3.3080409@linux.vnet.ibm.com>  <20080304103636.3e7b8fdd.akpm@linux-foundation.org>
  <47CDA081.7070503@cs.helsinki.fi> <20080304193532.GC9051@csn.ul.ie>
 <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
 <Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linuxppc-dev@ozlabs.org, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Pekka J Enberg wrote:

> On Tue, 4 Mar 2008, Christoph Lameter wrote:
> > Slab allocations should never be passed these flags since the slabs do 
> > their own thing there.
> > 
> > The following patch would clear these in slub:
> 
> Here's the same fix for SLAB:

That is an immediate fix ok. But there must be some location where SLAB 
does the masking of the gfp bits where things go wrong. Looking for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
