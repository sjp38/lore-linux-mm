Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9026B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 16:34:39 -0400 (EDT)
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
From: Daniel Walker <dwalker@codeaurora.org>
In-Reply-To: <op.vf7mvhvn7p4s8u@pikus>
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
	 <1279738688.31376.24.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf7j13067p4s8u@pikus>
	 <1279741029.31376.33.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf7lipj67p4s8u@pikus>
	 <1279742604.31376.40.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf7mvhvn7p4s8u@pikus>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Jul 2010 13:34:32 -0700
Message-ID: <1279744472.31376.42.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-07-21 at 22:22 +0200, MichaA? Nazarewicz wrote:
> On Wed, 21 Jul 2010 22:03:24 +0200, Daniel Walker <dwalker@codeaurora.org> wrote:
> 
> > On Wed, 2010-07-21 at 21:53 +0200, MichaA? Nazarewicz wrote:
> >> On Wed, 21 Jul 2010 21:37:09 +0200, Daniel Walker <dwalker@codeaurora.org> wrote:
> >> > What makes you assume that the bootloader would have these strings?
> >> > Do your devices have these strings? Maybe mine don't have them.
> >>
> >> I don't assume.  I only state it as one of the possibilities.
> >>
> >> > Assume the strings are gone and you can't find them, or have no idea
> >> > what they should be. What do you do then?
> >>
> >> Ask Google?
> >
> > Exactly, that's why they need to be in the kernel ..
> 
> Right.....  Please show me a place where I've written that it won't be in
> the kernel? I keep repeating command line is only one of the possibilities.
> I would imagine that in final product defaults from platform would be used
> and bootloader would be left alone.

It should never be anyplace else.

Daniel

-- 
Sent by an consultant of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
