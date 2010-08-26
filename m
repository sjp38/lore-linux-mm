Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 72F116B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 05:29:23 -0400 (EDT)
Received: by iwn33 with SMTP id 33so1883723iwn.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 02:29:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1282810811.1975.246.camel@laptop>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
	<20100825173125.0855a6b0@bike.lwn.net>
	<AANLkTinPaq+0MbdW81uoc5_OZ=1Gy_mVYEBnwv8zgOBd@mail.gmail.com>
	<1282810811.1975.246.camel@laptop>
Date: Thu, 26 Aug 2010 18:29:21 +0900
Message-ID: <AANLkTin7EBZw0-WY=NGOmYzZT5Cfy7oWVFBaT2cjK+vZ@mail.gmail.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 5:20 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2010-08-26 at 11:49 +0900, Minchan Kim wrote:
>> But one of
>> problems is anonymous page which can be has a role of pinned page in
>> non-swapsystem.
>
> Well, compaction can move those around, but if you've got too many of
> them its a simple matter of over-commit and for that we've got the
> OOM-killer ;-)
>

As I said following mail, I said about free space problem.
Of course, compaction could move anon pages into somewhere.
What's is somewhere? At last, it's same zone.
It can prevent fragment problem but not size of free space.
So I mean it would be better to move it into another zone(ex, HIGHMEM)
rather than OOM kill.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
