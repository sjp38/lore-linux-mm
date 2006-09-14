Date: Thu, 14 Sep 2006 09:55:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
In-Reply-To: <4509185B.1020901@sgi.com>
Message-ID: <Pine.LNX.4.64.0609140948240.23909@schroedinger.engr.sgi.com>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
 <1158046205.2992.1.camel@laptopd505.fenrus.org>
 <Pine.LNX.4.64.0609121024290.11188@schroedinger.engr.sgi.com>
 <yq0d5a0fbcj.fsf@jaguar.mkp.net> <Pine.LNX.4.64.0609130109030.15792@schroedinger.engr.sgi.com>
 <4507D4EE.4060501@sgi.com> <Pine.LNX.4.64.0609131015360.17927@schroedinger.engr.sgi.com>
 <20060913174948.GA6533@sgi.com> <Pine.LNX.4.64.0609131056260.18136@schroedinger.engr.sgi.com>
 <4509185B.1020901@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jes Sorensen <jes@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Sep 2006, Jes Sorensen wrote:

> I don't know about USB on ia64, but USB is an issue and we do support
> it even on Altix, as crazy as it may seem (I use USB with my SGI Prism
> foot-warmer in the office). Also take into account that some ia64 boxes
> do not come with IOMMU's, DIG - be afraid, be very afraid. On those
> machines you ideally want to have DMA32 zone for this stuff to support
> 32 bit PCI devices, even if the swiotlb can be used (bounce buffers for
> all transactions is just a sick idea), and we get back to the issue of
> using generic kernels.

USB sticks that use ISA DMA is an issue but then IA64 does not 
support ISA DMA at all and would not even now support that USB stick type.

> I agree it sounds appealing, but if reality is that all distro kernels
> will switch ZONE_DMA on, then having the option to switch it off is
> going have little or zero impact on the end users.

I am sure that if we keep ZONE_DMA unconfigurable then the distros will 
never switch that off because they cannot. On the other hand if its 
optional then it can be switched off at some future date or special 
kernels can be build if this will turn out to be a big advantage.

Also not everyone (even we have the capability of generatic static SGI 
specific kernels) uses only distro kernels and this is a big memory saver 
and reduces complexity in the kernel with only a single zone.
 
> In other words, will this really matter in end user situations?

Certainly it will never have a change of mattering if we keep the 
chicken-and-egg argument going.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
