Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA8A86B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 14:56:52 -0400 (EDT)
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
From: Daniel Walker <dwalker@codeaurora.org>
In-Reply-To: <op.vf7h1yc47p4s8u@pikus>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
	 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
	 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
	 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf5o28st7p4s8u@pikus>
	 <1279654698.26765.31.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf6zo9vb7p4s8u@pikus>
	 <1279733750.31376.14.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf7gt3qy7p4s8u@pikus>
	 <1279736348.31376.20.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf7h1yc47p4s8u@pikus>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Jul 2010 11:58:08 -0700
Message-ID: <1279738688.31376.24.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-07-21 at 20:38 +0200, MichaA? Nazarewicz wrote:
> > On Wed, 2010-07-21 at 20:11 +0200, MichaA? Nazarewicz wrote:
> >> Not really.  This will probably be used mostly on embedded systems
> >> where users don't have much to say as far as hardware included on the
> >> platform is concerned, etc.  Once a phone, tablet, etc. is released
> >> users will have little need for customising those strings.
> 
> On Wed, 21 Jul 2010 20:19:08 +0200, Daniel Walker <dwalker@codeaurora.org> wrote:
> > You can't assume that user won't want to reflash their own kernel on the
> > device. Your assuming way too much.
> 
> If user is clever enough to reflash a phone she will find the strings
> easy especially that they are provided from: (i) bootloader which is
> even less likely to be reflashed and if someone do reflash bootloader
> she is a guru who'd know how to make the strings; or (ii) platform
> defaults which will be available with the rest of the source code
> for the platform.

Your, again, assuming all sorts of stuff .. On my phone for example it
is very easy to reflash, personally, I think most devices will be like
that in the future. so you don't _need_ to be clever to reflash the
device.

> > If you assume they do want their own kernel then they would need this
> > string from someplace. If your right and this wouldn't need to change,
> > why bother allowing it to be configured at all ?
> 
> Imagine a developer who needs to recompile the kernel and reflash the
> device each time she wants to change the configuration...  Command line
> arguments seems a better option for development.

So make it a default off debug configuration option ..

Daniel

-- 
Sent by an consultant of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
