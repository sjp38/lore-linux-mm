Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 55DC16B0034
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 14:07:58 -0400 (EDT)
Message-ID: <520D18F7.5000801@linux.intel.com>
Date: Thu, 15 Aug 2013 11:07:51 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm/vmalloc: use wrapper function get_vm_area_size
 to caculate size of vm area
References: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com> <1376526703-2081-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1376526703-2081-4-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/14/2013 05:31 PM, Wanpeng Li wrote:
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 93d3182..553368c 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1553,7 +1553,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	unsigned int nr_pages, array_size, i;
>  	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
>  
> -	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
> +	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
>  	array_size = (nr_pages * sizeof(struct page *));

I guess this is fine, but I do see this same kind of use in a couple of
other spots in the kernel.  Was there a reason for doing this in this
one spot but ignoring the others?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
