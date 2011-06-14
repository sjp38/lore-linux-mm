Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 82C046B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 17:01:29 -0400 (EDT)
Message-ID: <4DF7CC22.6050602@codeaurora.org>
Date: Tue, 14 Jun 2011 15:01:22 -0600
From: Jordan Crouse <jcrouse@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory	Allocator
 added
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>	<20110614170158.GU2419@fooishbar.org>	<BANLkTi=cJisuP8=_YSg4h-nsjGj3zsM7sg@mail.gmail.com> <201106142242.25157.arnd@arndb.de>
In-Reply-To: <201106142242.25157.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Zach Pfeffer <zach.pfeffer@linaro.org>, linux-arm-kernel@lists.infradead.org, Daniel Walker <dwalker@codeaurora.org>, Daniel Stone <daniels@collabora.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-media@vger.kernel.org

On 06/14/2011 02:42 PM, Arnd Bergmann wrote:
> On Tuesday 14 June 2011 20:58:25 Zach Pfeffer wrote:
>> I've seen this split bank allocation in Qualcomm and TI SoCs, with
>> Samsung, that makes 3 major SoC vendors (I would be surprised if
>> Nvidia didn't also need to do this) - so I think some configurable
>> method to control allocations is necessarily. The chips can't do
>> decode without it (and by can't do I mean 1080P and higher decode is
>> not functionally useful). Far from special, this would appear to be
>> the default.
>
> Thanks for the insight, that's a much better argument than 'something
> may need it'. Are those all chips without an IOMMU or do we also
> need to solve the IOMMU case with split bank allocation?

Yes. The IOMMU case with split bank allocation is key, especially for shared
buffers. Consider the case where video is using a certain bank for performance
purposes and that frame is shared with the GPU.

Jordan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
