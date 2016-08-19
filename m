Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9CC6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 05:57:10 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so73489741pab.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 02:57:10 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id n8si7581576pay.18.2016.08.19.02.57.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 02:57:09 -0700 (PDT)
Subject: Re: [RFC PATCH] arm64/hugetlb enable gigantic hugepage
References: <1471521929-9207-1-git-send-email-xieyisheng1@huawei.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <68b492dc-06ea-dd33-2197-1f4b71d36072@huawei.com>
Date: Fri, 19 Aug 2016 17:49:38 +0800
MIME-Version: 1.0
In-Reply-To: <1471521929-9207-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, mhocko@suse.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, hillf.zj@alibaba-inc.com, dingel@linux.vnet.ibm.com, sfr@canb.auug.org.au, kirill.shutemov@linux.intel.comsudeep.holla@arm.com

add more,

hi all,
Could anyone do me a favor and give some comments?

Thanks
Xie Yisheng

On 2016/8/18 20:05, Xie Yisheng wrote:
> As we know, arm64 also support gigantic hugepage eg. 1G.
> So I try to use this function by adding hugepagesz=1G
> in kernel parameters, with CONFIG_CMA=y.
> However, when:
> echo xx > /sys/kernel/mm/hugepages/hugepages-1048576kB/
>           nr_hugepages
> it failed with the info:
> -bash: echo: write error: Invalid argument
> 
> This patch make gigantic hugepage can be used on arm64,
> when CONFIG_CMA=y or other related configs is enable.
> 
> Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>
> ---
>  mm/hugetlb.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 87e11d8..b4d8048 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1022,7 +1022,8 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>  		nr_nodes--)
>  
> -#if (defined(CONFIG_X86_64) || defined(CONFIG_S390)) && \
> +#if (defined(CONFIG_X86_64) || defined(CONFIG_S390) || \
> +	defined(CONFIG_ARM64)) && \
>  	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
>  	defined(CONFIG_CMA))
>  static void destroy_compound_gigantic_page(struct page *page,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
