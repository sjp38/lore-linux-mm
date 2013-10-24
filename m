Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1B96B00DD
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 13:30:43 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so2725096pdj.8
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 10:30:43 -0700 (PDT)
Received: from psmtp.com ([74.125.245.158])
        by mx.google.com with SMTP id zl9si1530440pbc.234.2013.10.24.10.30.41
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 10:30:42 -0700 (PDT)
Message-ID: <5269593D.8000904@iki.fi>
Date: Thu, 24 Oct 2013 20:30:37 +0300
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] memcg, kmem: Use is_root_cache instead of hard code
References: <1382527875-10112-1-git-send-email-h.huangqiang@huawei.com> <1382527875-10112-2-git-send-email-h.huangqiang@huawei.com>
In-Reply-To: <1382527875-10112-2-git-send-email-h.huangqiang@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org, penberg@kernel.org, glommer@parallels.com, rientjes@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On 10/23/2013 02:31 PM, Qiang Huang wrote:
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
> ---
>   mm/memcontrol.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b73988a..15ad0e3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -57,6 +57,7 @@
>   #include <net/sock.h>
>   #include <net/ip.h>
>   #include <net/tcp_memcontrol.h>
> +#include "slab.h"
>   
>   #include <asm/uaccess.h>
>   
> @@ -3064,7 +3065,7 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
>   {
>   	struct memcg_cache_params *cur_params = s->memcg_params;
>   
> -	VM_BUG_ON(s->memcg_params && !s->memcg_params->is_root_cache);
> +	VM_BUG_ON(!is_root_cache(s));
>   
>   	if (num_groups > memcg_limited_groups_array_size) {
>   		int i;

Reviewed-by: Pekka Enberg <penberg@kernel.org>

Andrew, I think your tree is the right place for these patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
