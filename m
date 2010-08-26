Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 186126B02CA
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 21:49:37 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7Q00ACGL2N6G90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 02:49:36 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Q006TYL2MDH@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 02:49:34 +0100 (BST)
Date: Thu, 26 Aug 2010 03:49:00 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100825173125.0855a6b0@bike.lwn.net>
Message-id: <op.vh0vbys97p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop>
 <20100825155814.25c783c7.akpm@linux-foundation.org>
 <20100825173125.0855a6b0@bike.lwn.net>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010 01:31:25 +0200, Jonathan Corbet <corbet@lwn.net> wro=
te:
> The original OLPC has a camera controller which requires three contigu=
ous,
> image-sized buffers in memory.  That system is a little memory constra=
ined
> (OK, it's desperately short of memory), so, in the past, the chances o=
f
> being able to allocate those buffers anytime some kid decides to start=

> taking pictures was poor.  Thus, cafe_ccic.c has an option to snag the=

> memory at initialization time and never let go even if you threaten it=
s
> family.  Hell hath no fury like a little kid whose new toy^W education=
al
> tool stops taking pictures.
>
> That, of course, is not a hugely efficient use of memory on a
> memory-constrained system.  If the VM could reliably satisfy those
> allocation requestss, life would be wonderful.  Seems difficult.  But =
it
> would be a nicer solution than CMA, which, to a great extent, is reall=
y
> just a standardized mechanism for grabbing memory and never letting go=
