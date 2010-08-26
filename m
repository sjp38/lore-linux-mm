Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5944F6B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 04:19:04 -0400 (EDT)
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <op.vh0xp8ix7p4s8u@localhost>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	 <1282310110.2605.976.camel@laptop>
	 <20100825155814.25c783c7.akpm@linux-foundation.org>
	 <op.vh0xp8ix7p4s8u@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 26 Aug 2010 10:18:57 +0200
Message-ID: <1282810737.1975.240.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-08-26 at 04:40 +0200, Micha=C5=82 Nazarewicz wrote:
> I think that the biggest problem is fragmentation here.  For instance,
> I think that a situation where there is enough free space but it's
> fragmented so no single contiguous chunk can be allocated is a serious
> problem.  However, I would argue that if there's simply no space left,
> a multimedia device could fail and even though it's not desirable, it
> would not be such a big issue in my eyes.
>=20
> So, if only movable or discardable pages are allocated in CMA managed
> regions all should work well.  When a device needs memory discardable
> pages would get freed and movable moved unless there is no space left
> on the device in which case allocation would fail.=20

If you'd actually looked at the page allocator you'd see its capable of
doing exactly that!

I has the notion of movable pages, it can defragment free space (called
compaction).

Use it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
