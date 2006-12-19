Date: Tue, 19 Dec 2006 20:01:15 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] handle SLOB with sparsemen
In-Reply-To: <20061218213009.91101cdd.randy.dunlap@oracle.com>
References: <20061218213009.91101cdd.randy.dunlap@oracle.com>
Message-Id: <20061219195657.6835.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm <akpm@osdl.org>
Cc: linux-mm@kvack.org, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

> (seems to have been lost)

Ah, yes. Andrew-san, please apply.

> 
> This is to disallow to make SLOB with SMP or SPARSEMEM.
> This avoids latent troubles of SLOB with SLAB_DESTROY_BY_RCU.
> And fix compile error.
> 
> This patch is for 2.6.19-rc5-mm2.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
> Acked-by: Hugh Dickins <hugh@veritas.com>
> ----
>  init/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.20-rc1-mm1.orig/init/Kconfig
> +++ linux-2.6.20-rc1-mm1/init/Kconfig
> @@ -476,7 +476,7 @@ config SHMEM
>  
>  config SLAB
>  	default y
> -	bool "Use full SLAB allocator" if EMBEDDED
> +	bool "Use full SLAB allocator" if (EMBEDDED && !SMP && !SPARSEMEM)
>  	help
>  	  Disabling this replaces the advanced SLAB allocator and
>  	  kmalloc support with the drastically simpler SLOB allocator.
> 
> 
> ---

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
