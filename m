Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0FAB46B00CE
	for <linux-mm@kvack.org>; Wed, 13 May 2009 04:51:26 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so344113wfa.11
        for <linux-mm@kvack.org>; Wed, 13 May 2009 01:52:12 -0700 (PDT)
Date: Wed, 13 May 2009 17:51:52 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED
 submenu
Message-Id: <20090513175152.1590c117.minchan.kim@barrios-desktop>
In-Reply-To: <20090513172904.7234.A69D9226@jp.fujitsu.com>
References: <20090513172904.7234.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi, Kosaki. 

On Wed, 13 May 2009 17:30:45 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] Kconfig: CONFIG_UNEVICTABLE_LRU move into EMBEDDED submenu
> 
> Almost people always turn on CONFIG_UNEVICTABLE_LRU. this configuration is
> used only embedded people.

I think at least embedded guys don't need it. 
But I am not sure other guys. 

> Thus, moving it into embedded submenu is better.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> ---
>  init/Kconfig |   12 ++++++++++++
>  mm/Kconfig   |   12 ------------
>  2 files changed, 12 insertions(+), 12 deletions(-)
> 
> Index: b/mm/Kconfig
> ===================================================================
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -203,18 +203,6 @@ config VIRT_TO_BUS
>  	def_bool y
>  	depends on !ARCH_NO_VIRT_TO_BUS
>  
> -config UNEVICTABLE_LRU
> -	bool "Add LRU list to track non-evictable pages"
> -	default y
> -	help
> -	  Keeps unevictable pages off of the active and inactive pageout
> -	  lists, so kswapd will not waste CPU time or have its balancing
> -	  algorithms thrown off by scanning these pages.  Selecting this
> -	  will use one page flag and increase the code size a little,
> -	  say Y unless you know what you are doing.
> -
> -	  See Documentation/vm/unevictable-lru.txt for more information.
> -
>  config HAVE_MLOCK
>  	bool
>  	default y if MMU=y
> Index: b/init/Kconfig
> ===================================================================
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -954,6 +954,18 @@ config SLUB_DEBUG
>  	  SLUB sysfs support. /sys/slab will not exist and there will be
>  	  no support for cache validation etc.
>  
> +config UNEVICTABLE_LRU
> +	bool "Add LRU list to track non-evictable pages" if EMBEDDED
> +	default y

If you want to move, it would be better as following.

config UNEVICTABLE_LRU
       bool "Add LRU list to track non-evictable pages" if EMBEDDED
       default !EMBEDDED

For embedded, it is disabled by default. 

> +	help
> +	  Keeps unevictable pages off of the active and inactive pageout
> +	  lists, so kswapd will not waste CPU time or have its balancing
> +	  algorithms thrown off by scanning these pages.  Selecting this
> +	  will use one page flag and increase the code size a little,
> +	  say Y unless you know what you are doing.
> +
> +	  See Documentation/vm/unevictable-lru.txt for more information.
> +
>  config STRIP_ASM_SYMS
>  	bool "Strip assembler-generated symbols during link"
>  	default n
> 
> 


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
