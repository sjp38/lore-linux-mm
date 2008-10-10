Subject: Re: [PATCH] Markers : revert synchronize marker unregister static
	inline
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20081010073749.GD23247@Krystal>
References: <20081009164700.c9042902.akpm@linux-foundation.org>
	 <20081009170349.35e0df12.akpm@linux-foundation.org>
	 <1223621125.8959.9.camel@penberg-laptop> <20081010071815.GA23247@Krystal>
	 <20081010072334.GA15715@elte.hu>  <20081010073749.GD23247@Krystal>
Date: Fri, 10 Oct 2008 10:43:09 +0300
Message-Id: <1223624589.8959.32.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-10 at 03:37 -0400, Mathieu Desnoyers wrote:
> Use a #define for synchronize marker unregister to fix include
> dependencies.

Looks good to me. Maybe you want to explicitly mention the connection
with slab in the changelog though? Otherwise someone else will go and
break the thing giving Andrew yet another excuse to drop my tree. :-)

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> CC: cl@linux-foundation.org
> ---
>  include/linux/marker.h |    6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> Index: linux-2.6-lttng/include/linux/marker.h
> ===================================================================
> --- linux-2.6-lttng.orig/include/linux/marker.h	2008-10-10 03:28:03.000000000 -0400
> +++ linux-2.6-lttng/include/linux/marker.h	2008-10-10 03:28:05.000000000 -0400
> @@ -13,7 +13,6 @@
>   */
>  
>  #include <linux/types.h>
> -#include <linux/rcupdate.h>
>  
>  struct module;
>  struct marker;
> @@ -166,9 +165,6 @@ extern void *marker_get_private_data(con
>   * unregistration and the end of module exit to make sure there is no caller
>   * executing a probe when it is freed.
>   */
> -static inline void marker_synchronize_unregister(void)
> -{
> -	synchronize_sched();
> -}
> +#define marker_synchronize_unregister() synchronize_sched()
>  
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
