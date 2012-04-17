Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E9AA06B0083
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:18:10 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so4960634qcs.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 11:18:10 -0700 (PDT)
Message-ID: <4F8DB3DC.7000602@gmail.com>
Date: Tue, 17 Apr 2012 14:18:04 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] ARM: remove consistent dma region and use common
 vmalloc range for dma allocations
References: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com> <1334325950-7881-5-git-send-email-m.szyprowski@samsung.com> <20120413183813.GO24211@n2100.arm.linux.org.uk> <4F8B76B9.1060505@kernel.org>
In-Reply-To: <4F8B76B9.1060505@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>, kosaki.motohiro@gmail.com

(4/15/12 9:32 PM), Minchan Kim wrote:
> On 04/14/2012 03:38 AM, Russell King - ARM Linux wrote:
>> On Fri, Apr 13, 2012 at 04:05:50PM +0200, Marek Szyprowski wrote:
>>> This patch changes dma-mapping subsystem to use generic vmalloc areas
>>> for all consistent dma allocations. This increases the total size limit
>>> of the consistent allocations and removes platform hacks and a lot of
>>> duplicated code.
>>
>> NAK. I don't think you appreciate the contexts from which the dma coherent
>> code can be called from, and the reason why we pre-allocate the page
>> tables (so that IRQ-based allocations work.)
>>
>> The vmalloc region doesn't allow that because page tables are allocated
>> using GFP_KERNEL not GFP_ATOMIC.
>>
>> Sorry.
>>
>
> Off-topic.
>
> I don't know why vmalloc functions have gfp_t argument.
> As Russel pointed out, we allocates page tables with GFP_KERNEL regardless of gfp_t passed.
> It means gfp_t passed is useless.
> I see there are many cases calling __vmalloc with GFP_NOFS, even GFP_ATOMIC. Then, it could end up deadlocking in reclaim context or schedule bug.
> I'm not sure why we can't see such bugs until now.
> If I didn't miss something, Shouldn't we fix it?

I believe it should be fixed. of course. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
