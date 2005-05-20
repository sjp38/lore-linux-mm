Date: Fri, 20 May 2005 11:27:31 +0900
From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Subject: Re: [ckrm-tech] [PATCH 2/6] CKRM: Core framework support
In-Reply-To: <20050519003205.GA25232@chandralinux.beaverton.ibm.com>
References: <20050519003205.GA25232@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20050520022732.A6646717AE@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 18 May 2005 17:32:05 -0700
Chandra Seetharaman <sekharan@us.ibm.com> wrote:

> Index: linux-2612-rc3/mm/page_alloc.c
> ===================================================================
> --- linux-2612-rc3.orig/mm/page_alloc.c
> +++ linux-2612-rc3/mm/page_alloc.c
> @@ -752,7 +752,7 @@ __alloc_pages(unsigned int __nocast gfp_
>  	 */
>  	can_try_harder = (unlikely(rt_task(p)) && !in_interrupt()) || !wait;
>  
> -	if (!ckrm_class_limit_ok(ckrm_get_mem_class(p)))
> +	if (!ckrm_class_limit_ok(ckrm_task_memclass(p)))
>  		return NULL;
>  
>  	zones = zonelist->zones;  /* the list of zones suitable for gfp_mask */

__alloc_pages() seems to look at the limit of the interrupted task
when an interrupt handler calls __alloc_pages().  It might be better
not to use ckrm_class_limit_ok() in in_interrupt() case, as we can't 
assume that the interrupt is caused by the interrupted task.

In can_try_harder case, how about trying to reclaim pages that belong
to the class if !ckrm_class_limit_ok() ?

Regards,

-- 
KUROSAWA, Takahiro
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
