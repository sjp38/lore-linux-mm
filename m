Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 85EB36B006E
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 21:58:05 -0500 (EST)
Message-ID: <50C00982.6020601@cn.fujitsu.com>
Date: Thu, 06 Dec 2012 10:57:06 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/5] page_alloc: Make movablecore_map has higher priority
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-5-git-send-email-tangchen@cn.fujitsu.com> <50BF6BA0.8060505@gmail.com> <50BFF443.3090504@cn.fujitsu.com> <50C00259.50901@huawei.com> <50C0081A.308@huawei.com>
In-Reply-To: <50C0081A.308@huawei.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Jiang Liu <liuj97@gmail.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Hi Liu, Wu,

I got it, thank you very much. The idea is very helpful. :)
I'll apply your patches and do some tests later.

Thanks. :)


On 12/06/2012 10:51 AM, Jianguo Wu wrote:
> Hi Tang,
>
> There is a bug in Gerry's patch, please apply this patch to fix it.
>
> ---
>   mm/page_alloc.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 41c3b51..d981810 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4383,7 +4383,7 @@ static int __init find_zone_movable_from_movablecore_map(void)
>   			 */
>   			start_pfn = max(start_pfn,
>   					movablecore_map.map[map_pos].start);
> -			zone_movable_pfn[nid] = roundup(zone_movable_pfn[nid],
> +			zone_movable_pfn[nid] = roundup(start_pfn,
>   							MAX_ORDER_NR_PAGES);
>   			break;
>   		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
