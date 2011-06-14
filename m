Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9F26B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:49:27 -0400 (EDT)
Message-ID: <4DF782F1.9030105@codeaurora.org>
Date: Tue, 14 Jun 2011 09:49:05 -0600
From: Jordan Crouse <jcrouse@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [PATCH 02/10] lib: genalloc: Generic allocator
 improvements
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>	<1307699698-29369-3-git-send-email-m.szyprowski@samsung.com>	<20110610122451.15af86d1@lxorguk.ukuu.org.uk>	<000c01cc2769$02669b70$0733d250$%szyprowski@samsung.com> <20110610135217.701a2fd2@lxorguk.ukuu.org.uk>
In-Reply-To: <20110610135217.701a2fd2@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On 06/10/2011 06:52 AM, Alan Cox wrote:
>> I plan to replace it with lib/bitmap.c bitmap_* based allocator (similar like
>> it it is used by dma_declare_coherent_memory() and friends in
>> drivers/base/dma-coherent.c). We need something really simple for CMA area
>> management.
>>
>> IMHO allocate_resource and friends a bit too heavy here, but good to know
>> that such allocator also exists.
>
> Not sure I'd class allocate_resource as heavyweight but providing it's
> using something that already exists rather than inventing yet another
> allocator.
>
> This wants dealing with before it goes upstream though so the chaneges in
> lib/*c etc never have to reach mainline and then get changed back.

Even if CMA doesn't end up using genalloc, there are existing consumers of
the API and I think the _aligned function has value.

I agree that allocate_resource isn't overly heavy, but comparatively genalloc
is really simple and lightweight for a driver to manage a contiguous address
space without a lot of extra thought. I think both APIs serve slightly
different masters, but if somebody thought about it long enough there could
be some consolidation (same goes for the internal guts of
dma_declare_coherent_memory).

I agree with Michal - if genalloc goes deprecated, then so be it, but as
long as it lives, I think its useful to get these functions upstream.

Jordan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
