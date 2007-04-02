Date: Mon, 2 Apr 2007 13:51:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <461169CF.6060806@google.com>
Message-ID: <Pine.LNX.4.64.0704021345110.1224@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
 <1175544797.22373.62.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
 <461169CF.6060806@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Martin Bligh wrote:

> > Its just the opposite. The vmemmap code is so efficient that we can remove
> > lots of other code and gops of these alternate implementations. On x86_64
> > its even superior to FLATMEM since FLATMEM still needs a memory reference
> > for the mem_map area. So if we make SPARSE standard for all configurations
> > then there is no need anymore for FLATMEM DISCONTIG etc etc. Can we not
> > cleanup all this mess? Get rid of all the gazillions of #ifdefs please? This
> > would ease code maintenance significantly. I hate having to constantly
> > navigate my way through all the alternatives.
> 
> The original plan when this was first merged was pretty much that -
> for sparsemem to replace discontigmem once it was well tested. Seems
> to have got stalled halfway through ;-(

But you made big boboo in SPARSEMEM. Virtual memmap is a textbook case 
that was not covered. Instead this horrible stuff that involves calling 
functions in VM primitives. We could have been there years ago...

> Not sure we'll get away with replacing flatmem for all arches, but
> we could at least get rid of discontigmem, it seems.

I think we could start with x86_64 and ia64. Both will work fine with 
SPARSE VIRTUAL (and SGIs concerns about performance are addressed) and we 
could remove the other alternatives. That is going to throw out lots of 
stuff. Then proceed to other arches

Could the SPARSEMEM folks take this over this patch? You have more 
resources and I am all alone on this. I will post another patchset today 
that also includes an IA64 implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
