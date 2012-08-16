Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 2759A6B006C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 04:21:46 -0400 (EDT)
Message-ID: <502CAD25.7060201@huawei.com>
Date: Thu, 16 Aug 2012 16:19:49 +0800
From: Hanjun Guo <guohanjun@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: introduce N_LRU_MEMORY to distinguish between
 normal and movable memory
References: <1344482788-4984-1-git-send-email-guohanjun@huawei.com> <50233EF5.3050605@huawei.com> <alpine.DEB.2.02.1208090900450.15909@greybox.home> <5024CADC.1010202@huawei.com> <alpine.DEB.2.02.1208100909410.3903@greybox.home> <502A3CD2.9000007@huawei.com> <00000139257cb4f7-55034aa0-7541-498a-9a3f-259435ccec65-000000@email.amazonses.com>
In-Reply-To: <00000139257cb4f7-55034aa0-7541-498a-9a3f-259435ccec65-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Wu Jianguo <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On 2012/8/14 22:14, Christoph Lameter wrote:
> On Tue, 14 Aug 2012, Hanjun Guo wrote:
> 
>> N_NORMAL_MEMORY means !LRU allocs possible.
> 
> Ok. I am fine with that change. However this is a significant change that
> needs to be mentioned prominently in the changelog and there need to be
> some comments explaining the meaning of these flags clearly in the source.

No problem, we will handle it in next version of this patch.

Thanks
Hanjun Guo

> 
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
