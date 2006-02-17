From: "Bob Picco" <bob.picco@hp.com>
Date: Fri, 17 Feb 2006 06:23:24 -0500
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
Message-ID: <20060217112324.GA31068@localhost>
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com> <20060217145409.4064.Y-GOTO@jp.fujitsu.com> <200602171058.33078.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200602171058.33078.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:	[Fri Feb 17 2006, 04:58:32AM EST]
> On Friday 17 February 2006 07:10, Yasunori Goto wrote:
> > > > Empty nodes are not initialization, but the node number is still
> > > > allocated. And then it would early except or even triple fault here
> > > > because it would try to set  up a fallback list for a NULL pgdat. Oops.
> > >
> > > Isnt this an issue with the arch code? Simply do not allocate an empty
> > > node. Is the mapping from linux Node id -> Hardware node id fixed on
> > > x86_64? ia64 has a lookup table.
> >
> > Do you mention about pxm_to_nid_map[]?
> 
> I think he refers to cpu_to_node[] 
> 
> > Ia64 added the feature of memory less node long time ago.
> 
> x86-64 too, but it just bitrotted and that is what I was trying to fix.
> I did some tests with a simulator in a few combinations of memory less
> CPUs and with the two patches they all boot so far. But will test it out more.
> 
> -Andi
> 
> --
Yasunori thanks for mentioning memory less nodes for ia64.  This is my
concern with the patch. I need to test/review the patch on HP 
hardware/simulator (most default configured HP NUMA machines are memory less - 
interleaved memory). This has caused us numerous NUMA issues.
 
bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
