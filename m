Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id C4B6B6B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:57:40 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id hy4so5169745vcb.19
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:57:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id n8si13920472qag.105.2014.06.16.09.57.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jun 2014 09:57:40 -0700 (PDT)
Message-ID: <539F21F4.20206@infradead.org>
Date: Mon, 16 Jun 2014 09:57:24 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] doc: update Documentation/sysctl/vm.txt
References: <539EB803.9070001@huawei.com>
In-Reply-To: <539EB803.9070001@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On 06/16/14 02:25, Xishi Qiu wrote:
> Update the doc.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  Documentation/sysctl/vm.txt |   43 +++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 43 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index dd9d0e3..8008e53 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -20,6 +20,10 @@ Currently, these files are in /proc/sys/vm:
>  
>  - admin_reserve_kbytes
>  - block_dump
> +- cache_limit_mbytes
> +- cache_limit_ratio
> +- cache_reclaim_s
> +- cache_reclaim_weight
>  - compact_memory
>  - dirty_background_bytes
>  - dirty_background_ratio
> @@ -97,6 +101,45 @@ information on block I/O debugging is in Documentation/laptops/laptop-mode.txt.
>  
>  ==============================================================
>  
> +cache_limit_mbytes
> +
> +This is used to limit page cache amount. The input unit is MB, value range
> +is from 0 to totalram_pages. If this is set to 0, it will not limit page cache.

Where does one find the value of totalram_pages?

Is totalram_pages in MB or does totalram_pages need to be divided by some value
to convert it to MB?

> +When written to the file, cache_limit_ratio will be updated too.
> +
> +The default value is 0.
> +
> +==============================================================
> +
> +cache_limit_ratio
> +
> +This is used to limit page cache amount. The input unit is percent, value
> +range is from 0 to 100. If this is set to 0, it will not limit page cache.
> +When written to the file, cache_limit_mbytes will be updated too.
> +
> +The default value is 0.
> +
> +==============================================================
> +
> +cache_reclaim_s
> +
> +This is used to reclaim page cache in circles. The input unit is second,
> +the minimum value is 0. If this is set to 0, it will disable the feature.
> +
> +The default value is 0.
> +
> +==============================================================
> +
> +cache_reclaim_weight
> +
> +This is used to speed up page cache reclaim. It depend on enabling

                                                   depends on

> +cache_limit_mbytes/cache_limit_ratio or cache_reclaim_s. Value range is
> +from 1(slow) to 100(fast).
> +
> +The default value is 1.
> +
> +==============================================================
> +
>  compact_memory
>  
>  Available only when CONFIG_COMPACTION is set. When 1 is written to the file,
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
