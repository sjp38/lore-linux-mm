Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 76B426B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 05:05:03 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so20304121lbj.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 02:05:01 -0700 (PDT)
Date: Mon, 9 Jul 2012 12:04:52 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 3/7] mm/slub.c: remove invalid reference to list iterator
 variable
In-Reply-To: <1341747464-1772-4-git-send-email-Julia.Lawall@lip6.fr>
Message-ID: <alpine.LFD.2.02.1207091204450.3050@tux.localdomain>
References: <1341747464-1772-1-git-send-email-Julia.Lawall@lip6.fr> <1341747464-1772-4-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: Christoph Lameter <cl@linux-foundation.org>, kernel-janitors@vger.kernel.org, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 8 Jul 2012, Julia Lawall wrote:

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> If list_for_each_entry, etc complete a traversal of the list, the iterator
> variable ends up pointing to an address at an offset from the list head,
> and not a meaningful structure.  Thus this value should not be used after
> the end of the iterator.  The patch replaces s->name by al->name, which is
> referenced nearby.
> 
> This problem was found using Coccinelle (http://coccinelle.lip6.fr/).
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  mm/slub.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index cc4ed03..ef9bf01 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5395,7 +5395,7 @@ static int __init slab_sysfs_init(void)
>  		err = sysfs_slab_alias(al->s, al->name);
>  		if (err)
>  			printk(KERN_ERR "SLUB: Unable to add boot slab alias"
> -					" %s to sysfs\n", s->name);
> +					" %s to sysfs\n", al->name);
>  		kfree(al);
>  	}

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
