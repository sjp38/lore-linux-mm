Date: Wed, 13 Sep 2006 12:49:48 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-ID: <20060913174948.GA6533@sgi.com>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com> <1158046205.2992.1.camel@laptopd505.fenrus.org> <Pine.LNX.4.64.0609121024290.11188@schroedinger.engr.sgi.com> <yq0d5a0fbcj.fsf@jaguar.mkp.net> <Pine.LNX.4.64.0609130109030.15792@schroedinger.engr.sgi.com> <4507D4EE.4060501@sgi.com> <Pine.LNX.4.64.0609131015360.17927@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609131015360.17927@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jes Sorensen <jes@sgi.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 13, 2006 at 10:23:10AM -0700, Christoph Lameter wrote:
> On Wed, 13 Sep 2006, Jes Sorensen wrote:
> 
> > > There was the floppy driver and one type of USB stick that I noticed 
> > > during the work on the project. But other drivers may depend also depend 
> > > indirectly on DMA functionality and may also be disabled.
> > 
> > Ok, USB should ring alarm bells, floppy I think is less relevant these
> > days :)
> 
> If you want all drivers then you must of course have ZONE_DMA. 
> Distributions that want to cover all drivers will have it on by default 
> and ZONE_DMA is available by default.
> 
> However, if you want to create a lean and mean kernel then you can switch 
> ZONE_DMA off and if there is just one zone left then the VM can 
> optimized much better because loops are avoided and some macros 
> become constant etc etc.
> 
> Some architectures never need ZONE_DMA because all hardware supports DMA 
> to all of memory. SGI Altix is one example. Carrying an additional 
> useless zone around unecessarily bloats the kernel both in term of code 
> and data. Data is a particular issue since zones contain per cpu elements. 
> For a 1k cpu 1k node configuration this saves around 1 million per cpu 
> structures (one zone per node with 1k per cpu pagesets).
> 

Most distros release GENERIC kernels for IA64. If _any_ IA64 platform requires 
ZONE_DMA, then it must be configured ON.

Two questions:

	- will any IA64 platform require that ZONE_DMA be enabled (I think
	  the answer is "yes")

	- if ZONE_DMA is enabled, ALTIX will still use only 1 zone. In your
	  statement above, you say that disabling ZONE_DMA save 1M cpu
	  structures. If ZONE_DMA is enabled, will these 1M structure be allocated
	  on SN even though they are not needed?

-- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
