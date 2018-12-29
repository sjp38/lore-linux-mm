Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C72E8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 05:02:25 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b185so29214698qkc.3
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 02:02:25 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 136si33946qke.143.2018.12.29.02.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Dec 2018 02:02:24 -0800 (PST)
Subject: Re: [PATCH] mm/slub.c: freelist is ensured to be NULL when new_slab()
 fails
References: <20181229062512.30469-1-rocking@whu.edu.cn>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <56ee5ac0-0785-cf2a-c1b4-95d4df2d11f1@iki.fi>
Date: Sat, 29 Dec 2018 12:02:14 +0200
MIME-Version: 1.0
In-Reply-To: <20181229062512.30469-1-rocking@whu.edu.cn>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peng Wang <rocking@whu.edu.cn>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 29/12/2018 8.25, Peng Wang wrote:
> new_slab_objects() will return immediately if freelist is not NULL.
> 
>           if (freelist)
>                   return freelist;
> 
> One more assignment operation could be avoided.
> 
> Signed-off-by: Peng Wang <rocking@whu.edu.cn>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

> ---
>   mm/slub.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 36c0befeebd8..cf2ef4ababff 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2463,8 +2463,7 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
>   		stat(s, ALLOC_SLAB);
>   		c->page = page;
>   		*pc = c;
> -	} else
> -		freelist = NULL;
> +	}
>   
>   	return freelist;
>   }
> 
