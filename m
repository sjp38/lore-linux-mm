Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 45C156B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:06:13 -0400 (EDT)
Date: Thu, 22 Jul 2010 10:06:04 +0100
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100722090602.GF10930@sirena.org.uk>
References: <cover.1279639238.git.m.nazarewicz@samsung.com> <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com> <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com> <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com> <op.vf5o28st7p4s8u@pikus> <20100721135229.GC10930@sirena.org.uk> <op.vf66mxka7p4s8u@pikus> <20100721182457.GE10930@sirena.org.uk> <op.vf7h6ysh7p4s8u@pikus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.vf7h6ysh7p4s8u@pikus>
Sender: owner-linux-mm@kvack.org
To: Micha?? Nazarewicz <m.nazarewicz@samsung.com>
Cc: Daniel Walker <dwalker@codeaurora.org>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 08:41:12PM +0200, Micha?? Nazarewicz wrote:
> On Wed, 21 Jul 2010 20:24:58 +0200, Mark Brown <broonie@opensource.wolfsonmicro.com> wrote:

> >> I am currently working on making the whole thing more dynamic.  I imagine

> > Yes, I think it will be much easier to be able to grab the regions at
> > startup but hopefully the allocation within those regions can be made
> > much more dynamic.  This would render most of the configuration syntax
> > unneeded.

> Not sure what you mean by the last sentence.  Maybe we have different
> things in mind?

I mean that if the drivers are able to request things dynamically and
have some knowledge of their own requirements then that removes the need
to manually specify exactly which regions go to which drivers which
means that most of the complexity of the existing syntax is not needed
since it can be figured out at runtime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
