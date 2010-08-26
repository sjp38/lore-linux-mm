Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2C80B6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 07:05:45 -0400 (EDT)
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTikS9Bc1NmCCO5w=pT+LBLaeSyk2PBnAry+oDxM8@mail.gmail.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	 <1282310110.2605.976.camel@laptop>
	 <20100825155814.25c783c7.akpm@linux-foundation.org>
	 <20100825173125.0855a6b0@bike.lwn.net>
	 <AANLkTinPaq+0MbdW81uoc5_OZ=1Gy_mVYEBnwv8zgOBd@mail.gmail.com>
	 <1282810811.1975.246.camel@laptop>
	 <AANLkTin7EBZw0-WY=NGOmYzZT5Cfy7oWVFBaT2cjK+vZ@mail.gmail.com>
	 <1282817160.1975.476.camel@laptop>
	 <AANLkTikS9Bc1NmCCO5w=pT+LBLaeSyk2PBnAry+oDxM8@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 26 Aug 2010 13:05:32 +0200
Message-ID: <1282820732.1975.606.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Even more offtopic ;-)

On Thu, 2010-08-26 at 19:21 +0900, Minchan Kim wrote:
> I agree highmem isn't a gorgeous. But my desktop isn't real machine?
> Important thing is that we already have a highmem and many guys
> include you(kmap stacking patch :))try to improve highmem problems. :)

I have exactly 0 machines in daily use that use highmem, I had to test
that kmap stuff in a 32bit qemu.

Sadly some hardware folks still think its a sane thing to do, like ARM
announcing 40bit PAE, I mean really?!

At least AMD announced a 64bit tiny-chip and hopefully Intel Atom will
soon be all 64bit too (please?!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
