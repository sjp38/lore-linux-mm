Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4DFC46B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:23:51 -0400 (EDT)
Date: Wed, 21 Jul 2010 19:24:58 +0100
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100721182457.GE10930@sirena.org.uk>
References: <cover.1279639238.git.m.nazarewicz@samsung.com> <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com> <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com> <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com> <op.vf5o28st7p4s8u@pikus> <20100721135229.GC10930@sirena.org.uk> <op.vf66mxka7p4s8u@pikus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.vf66mxka7p4s8u@pikus>
Sender: owner-linux-mm@kvack.org
To: Micha?? Nazarewicz <m.nazarewicz@samsung.com>
Cc: Daniel Walker <dwalker@codeaurora.org>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 04:31:35PM +0200, Micha?? Nazarewicz wrote:
> On Wed, 21 Jul 2010 15:52:30 +0200, Mark Brown <broonie@opensource.wolfsonmicro.com> wrote:

> > If this does need to be configured per system would having platform data
> > of some kind in the kernel not be a sensible a place to do it,

> The current version (and the next version I'm working on) of the code
> has cma_defaults() call.  It is intended to be called from platform
> initialisation code to provide defaults.

So the command line is just a way of overriding that?  That makes things
a lot nicer - normally the device would use the defaults and the command
line would be used in development.

> > or even
> > having a way of configuring this at runtime (after all, the set of
> > currently active users may vary depending on the current configuration
> > and keeping everything allocated all the time may be wasteful)?

> I am currently working on making the whole thing more dynamic.  I imagine
> the list of regions would stay pretty much the same after kernel has
> started (that's because one cannot reliably allocate new big contiguous
> memory regions) but it will be possible to change the set of rules, etc.

Yes, I think it will be much easier to be able to grab the regions at
startup but hopefully the allocation within those regions can be made
much more dynamic.  This would render most of the configuration syntax
unneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
