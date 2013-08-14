Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6817C6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:54:53 -0400 (EDT)
Date: Wed, 14 Aug 2013 17:54:25 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1376517265-8yi1139t-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1375956979-31877-6-git-send-email-tangchen@cn.fujitsu.com>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
 <1375956979-31877-6-git-send-email-tangchen@cn.fujitsu.com>
Subject: Re: [PATCH part5 5/7] memblock, mem_hotplug: Make memblock skip
 hotpluggable regions by default.
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, Aug 08, 2013 at 06:16:17PM +0800, Tang Chen wrote:
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
...
> @@ -719,6 +723,10 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
>  		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
>  			continue;
>  
> +		/* skip hotpluggable memory regions */
> +		if (m->flags & MEMBLOCK_HOTPLUG)
> +			continue;
> +
>  		/* scan areas before each reservation for intersection */
>  		for ( ; ri >= 0; ri--) {
>  			struct memblock_region *r = &rsv->regions[ri];
> -- 

Why don't you add this also in __next_free_mem_range()?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
