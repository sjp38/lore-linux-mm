Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B8CB6900114
	for <linux-mm@kvack.org>; Thu,  5 May 2011 15:46:00 -0400 (EDT)
Date: Thu, 5 May 2011 12:45:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cpumask: alloc_cpumask_var() use NUMA_NO_NODE
Message-Id: <20110505124556.3c8a7e5b.akpm@linux-foundation.org>
In-Reply-To: <20110428231856.3D54.A69D9226@jp.fujitsu.com>
References: <20110428231856.3D54.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 28 Apr 2011 23:17:15 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> NUMA_NO_NODE and numa_node_id() are different meanings. NUMA_NO_NODE 
> is obviously recomended fallback.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  lib/cpumask.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/cpumask.c b/lib/cpumask.c
> index 4f6425d..af3e581 100644
> --- a/lib/cpumask.c
> +++ b/lib/cpumask.c
> @@ -131,7 +131,7 @@ EXPORT_SYMBOL(zalloc_cpumask_var_node);
>   */
>  bool alloc_cpumask_var(cpumask_var_t *mask, gfp_t flags)
>  {
> -	return alloc_cpumask_var_node(mask, flags, numa_node_id());
> +	return alloc_cpumask_var_node(mask, flags, NUMA_NO_NODE);
>  }
>  EXPORT_SYMBOL(alloc_cpumask_var);
>  

So effectively this will replace numa_node_id() with numa_mem_id(),
yes?  What runtime effects might this have?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
