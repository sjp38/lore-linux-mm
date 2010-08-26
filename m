Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E8C2F6B01F0
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 01:50:07 -0400 (EDT)
Received: by pxi5 with SMTP id 5so601052pxi.14
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 22:50:07 -0700 (PDT)
Date: Thu, 26 Aug 2010 13:54:17 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-ID: <20100826055417.GA5157@cr0.nay.redhat.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop>
 <20100825155814.25c783c7.akpm@linux-foundation.org>
 <20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
 <op.vh0wektv7p4s8u@localhost>
 <20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
 <20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
 <op.vh01hi2m7p4s8u@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.vh01hi2m7p4s8u@localhost>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Hans Verkuil <hverkuil@xs4all.nl>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 06:01:56AM +0200, MichaA? Nazarewicz wrote:
>KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>128MB...too big ? But it's depend on config.
>
>On embedded systems it may be like half of the RAM.  Or a quarter.  So bigger
>granularity could be desired on some platforms.
>
>>IBM's ppc guys used 16MB section, and recently, a new interface to shrink
>>the number of /sys files are added, maybe usable.
>>
>>Something good with this approach will be you can create "cma" memory
>>before installing driver.
>
>That's how CMA works at the moment.  But if I understand you correctly, what
>you are proposing would allow to reserve memory *at* *runtime* long after system
>has booted.  This would be a nice feature as well though.
>

Yeah, if we can do this, that will avoid rebooting for kdump to reserve
memory.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
