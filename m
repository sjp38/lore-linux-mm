From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
Date: Fri, 17 Feb 2006 10:58:32 +0100
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com> <20060217145409.4064.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060217145409.4064.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602171058.33078.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 17 February 2006 07:10, Yasunori Goto wrote:
> > > Empty nodes are not initialization, but the node number is still
> > > allocated. And then it would early except or even triple fault here
> > > because it would try to set  up a fallback list for a NULL pgdat. Oops.
> >
> > Isnt this an issue with the arch code? Simply do not allocate an empty
> > node. Is the mapping from linux Node id -> Hardware node id fixed on
> > x86_64? ia64 has a lookup table.
>
> Do you mention about pxm_to_nid_map[]?

I think he refers to cpu_to_node[] 

> Ia64 added the feature of memory less node long time ago.

x86-64 too, but it just bitrotted and that is what I was trying to fix.
I did some tests with a simulator in a few combinations of memory less
CPUs and with the two patches they all boot so far. But will test it out more.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
