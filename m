Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D35126B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 14:48:03 -0400 (EDT)
Message-ID: <50160.128.237.237.232.1366053081.squirrel@mprc.pku.edu.cn>
In-Reply-To: <1365867399-21323-17-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
    <1365867399-21323-17-git-send-email-jiang.liu@huawei.com>
Date: Tue, 16 Apr 2013 03:11:21 +0800 (CST)
Subject: Re: [RFC PATCH v1 16/19] mm/unicore32: fix stale comment about
     VALID_PAGE()
From: "Xuetao Guan" <gxt@mprc.pku.edu.cn>
Reply-To: gxt@mprc.pku.edu.cn
MIME-Version: 1.0
Content-Type: text/plain;charset=gb2312
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>

> VALID_PAGE() has been removed from kernel long time ago,
> so fix the comment.
>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> Cc: linux-kernel@vger.kernel.org

Thanks,

Acked-by: Guan Xuetao <gxt@mprc.pku.edu.cn>

> ---
>  arch/unicore32/include/asm/memory.h |    6 ------
>  1 file changed, 6 deletions(-)
>
> diff --git a/arch/unicore32/include/asm/memory.h
> b/arch/unicore32/include/asm/memory.h
> index 5eddb99..debafc4 100644
> --- a/arch/unicore32/include/asm/memory.h
> +++ b/arch/unicore32/include/asm/memory.h
> @@ -98,12 +98,6 @@
>  /*
>   * Conversion between a struct page and a physical address.
>   *
> - * Note: when converting an unknown physical address to a
> - * struct page, the resulting pointer must be validated
> - * using VALID_PAGE().  It must return an invalid struct page
> - * for any physical address not corresponding to a system
> - * RAM address.
> - *
>   *  page_to_pfn(page)	convert a struct page * to a PFN number
>   *  pfn_to_page(pfn)	convert a _valid_ PFN number to struct page *
>   *
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
