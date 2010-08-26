Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 151256B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 04:20:36 -0400 (EDT)
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTinPaq+0MbdW81uoc5_OZ=1Gy_mVYEBnwv8zgOBd@mail.gmail.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	 <1282310110.2605.976.camel@laptop>
	 <20100825155814.25c783c7.akpm@linux-foundation.org>
	 <20100825173125.0855a6b0@bike.lwn.net>
	 <AANLkTinPaq+0MbdW81uoc5_OZ=1Gy_mVYEBnwv8zgOBd@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 26 Aug 2010 10:20:11 +0200
Message-ID: <1282810811.1975.246.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-08-26 at 11:49 +0900, Minchan Kim wrote:
> But one of
> problems is anonymous page which can be has a role of pinned page in
> non-swapsystem.=20

Well, compaction can move those around, but if you've got too many of
them its a simple matter of over-commit and for that we've got the
OOM-killer ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
