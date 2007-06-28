From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
Date: Thu, 28 Jun 2007 02:14:22 +0200
References: <20070625195224.21210.89898.sendpatchset@localhost> <200706280001.16383.ak@suse.de> <20070627234634.GI8604@linux.vnet.ibm.com>
In-Reply-To: <20070627234634.GI8604@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706280214.23054.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thursday 28 June 2007 01:46:34 Paul E. McKenney wrote:
> On Thu, Jun 28, 2007 at 12:01:16AM +0200, Andi Kleen wrote:
> > 
> > > The zonelist from MPOL_BIND is passed to __alloc_pages. As a result the 
> > > RCU lock must be held over the call into the page allocator with reclaim 
> > > etc etc. Note that the zonelist is part of the policy structure.
> > 
> > Yes I realized this at some point too. RCU doesn't work here because
> > __alloc_pages can sleep. Have to use the reference counts even though
> > it adds atomic operations.
> 
> Any reason SRCU wouldn't work here?  From a quick glance at the patch,
> it seems possible to me.

We have reference counts anyways that can be used so it's not needed.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
