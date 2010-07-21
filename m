Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BDAF76B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:18:01 -0400 (EDT)
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
From: Daniel Walker <dwalker@codeaurora.org>
In-Reply-To: <op.vf7gt3qy7p4s8u@pikus>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
	 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
	 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
	 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf5o28st7p4s8u@pikus>
	 <1279654698.26765.31.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf6zo9vb7p4s8u@pikus>
	 <1279733750.31376.14.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf7gt3qy7p4s8u@pikus>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Jul 2010 11:19:08 -0700
Message-ID: <1279736348.31376.20.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-07-21 at 20:11 +0200, MichaA? Nazarewicz wrote:

> >> > (btw, these strings your creating yikes, talk about confusing ..)
> >>
> >> They are not that scary really.  Let's look at cma:
> >>
> >> 	a=10M;b=10M
> >>
> >> Split it on semicolon:
> >>
> >> 	a=10M
> >> 	b=10M
> >>
> >> and you see that it defines two regions (a and b) 10M each.
> >
> > I think your assuming a lot .. I've never seen the notation before I
> > wouldn't assuming there's regions or whatever ..
> 
> That's why there is documentation with grammar included. :)
> 
> >> As of cma_map:
> >>
> >> 	camera,video=a;jpeg,scaler=b
> >>
> >> Again split it on semicolon:
> >>
> >> 	camera,video=a
> >> 	jpeg,scaler=b
> >>
> >> Now, substitute equal sign by "use(s) region(s)":
> >>
> >> 	camera,video	use(s) region(s):	a
> >> 	jpeg,scaler	use(s) region(s):	b
> >>
> >> No black magic here. ;)
> >
> > It way too complicated .. Users (i.e. not programmers) has to use
> > this ..
> 
> Not really.  This will probably be used mostly on embedded systems
> where users don't have much to say as far as hardware included on the
> platform is concerned, etc.  Once a phone, tablet, etc. is released
> users will have little need for customising those strings.

You can't assume that user won't want to reflash their own kernel on the
device. Your assuming way too much.

If you assume they do want their own kernel then they would need this
string from someplace. If your right and this wouldn't need to change,
why bother allowing it to be configured at all ?

Daniel

-- 
Sent by an consultant of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
