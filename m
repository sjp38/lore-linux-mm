Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 06E6F6B01F1
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 04:27:17 -0400 (EDT)
Message-ID: <4C7B6B86.3080502@ladisch.de>
Date: Mon, 30 Aug 2010 10:27:50 +0200
From: Clemens Ladisch <clemens@ladisch.de>
MIME-Version: 1.0
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
References: <cover.1282286941.git.m.nazarewicz@samsung.com>	<1282310110.2605.976.camel@laptop> <20100825155814.25c783c7.akpm@linux-foundation.org>
In-Reply-To: <20100825155814.25c783c7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> It would help (a lot) if we could get more attention and buyin and
> fedback from the potential clients of this code.  rmk's feedback is
> valuable.  Have we heard from the linux-media people?  What other
> subsystems might use it?  ieee1394 perhaps?

All FireWire controllers are OHCI and use scatter-gather lists.

Most USB controllers require continuous memory for USB packets; the USB
framework has its own DMA buffer cache.

Some sound cards have no IOMMU; the ALSA framework preallocates buffers
for those.


Regards,
Clemens

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
