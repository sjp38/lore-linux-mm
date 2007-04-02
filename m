Received: from midway.site ([71.245.96.31]) by xenotime.net for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:25:22 -0700
Date: Mon, 2 Apr 2007 15:27:19 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [KJ]  [PATCH] mm: spelling error in a comment
Message-Id: <20070402152719.e7b622ba.rdunlap@xenotime.net>
In-Reply-To: <20070402210636.GA14216@tux>
References: <20070402210636.GA14216@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Charles =?ISO-8859-1?Q?Cl=E9ment?= <caratorn@gmail.com>
Cc: kernel-janitors@lists.linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007 23:06:36 +0200 Charles Clement wrote:

> 
> Fix spelling in a comment in mm/slab.c.
> 
> Signed-off-by: Charles Clement <caratorn@gmail.com>

Alexey can grab this if he wants to (or Adrian could),
but here's what Andrew Morton has to say about such patches:

http://marc.info/?l=kernel-janitor-discuss&m=117360826232574&w=2

"...I prefer not to do spello and grammaro
fixes, unless they're in something user-visible: a printk or documentation.
Simply because there would be no end to it."


> ---
> 
> Index: linux-2.6.21-rc5/mm/slab.c
> ===================================================================
> --- linux-2.6.21-rc5.orig/mm/slab.c
> +++ linux-2.6.21-rc5/mm/slab.c
> @@ -451,7 +451,7 @@ struct kmem_cache {
>  
>  #define BATCHREFILL_LIMIT	16
>  /*
> - * Optimization question: fewer reaps means less probability for unnessary
> + * Optimization question: fewer reaps means less probability for unnecessary
>   * cpucache drain/refill cycles.
>   *
>   * OTOH the cpuarrays can contain lots of objects,
> 
> -- 
> Charles Clement.
> _______________________________________________
> Kernel-janitors mailing list
> Kernel-janitors@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/kernel-janitors
> 


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
