Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 482546B02A8
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 09:52:40 -0400 (EDT)
Date: Wed, 21 Jul 2010 14:52:30 +0100
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Message-ID: <20100721135229.GC10930@sirena.org.uk>
References: <cover.1279639238.git.m.nazarewicz@samsung.com> <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com> <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com> <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com> <op.vf5o28st7p4s8u@pikus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.vf5o28st7p4s8u@pikus>
Sender: owner-linux-mm@kvack.org
To: Micha?? Nazarewicz <m.nazarewicz@samsung.com>
Cc: Daniel Walker <dwalker@codeaurora.org>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 09:14:58PM +0200, Micha?? Nazarewicz wrote:
> On Tue, 20 Jul 2010 20:15:24 +0200, Daniel Walker <dwalker@codeaurora.org> wrote:

> > If you have this disconnected from the drivers it will just cause
> > confusion, since few will know what these parameters should be for a
> > given driver set. It needs to be embedded in the kernel.

> I see your point but the problem is that devices drivers don't know the
> rest of the system neither they know what kind of use cases the system
> should support.

If this does need to be configured per system would having platform data
of some kind in the kernel not be a sensible a place to do it, or even
having a way of configuring this at runtime (after all, the set of
currently active users may vary depending on the current configuration
and keeping everything allocated all the time may be wasteful)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
