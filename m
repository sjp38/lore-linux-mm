Date: Wed, 15 Mar 2006 11:00:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration: Fail with error if swap not setup
In-Reply-To: <20060315213904.GA13771@dmt.cnet>
Message-ID: <Pine.LNX.4.64.0603151059080.27630@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
 <1142434053.5198.1.camel@localhost.localdomain>
 <Pine.LNX.4.64.0603150901530.26799@schroedinger.engr.sgi.com>
 <20060315204742.GB12432@dmt.cnet> <Pine.LNX.4.64.0603151002490.27212@schroedinger.engr.sgi.com>
 <20060315213904.GA13771@dmt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, nickpiggin@yahoo.com.au, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Marcelo Tosatti wrote:

> > That does not answer the question if VM_LOCKED pages should be 
> > migratable. We all agree that they should not show up on swap.
> 
> I guess you missed the first part of the man page:
> 
> All pages which contain a part of the specified memory range are
> guaranteed be resident in RAM when the mlock system call returns
> successfully and they are guaranteed to stay in RAM until the pages are
> unlocked by munlock or munlockall, until the pages are unmapped via
> munmap, or until the process terminates or starts another program with
> exec. Child processes do not inherit page locks across a fork.
> 
> That is, mlock() only guarantees that pages are kept in RAM and not
> swapped. It does seem to refer to physical placing of pages.

If VM_LOCKED is not pinning memory then how does one pin memory? There are 
likely applications / drivers that require memory not to move. Increase 
pagecount?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
