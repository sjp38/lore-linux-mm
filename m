Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A68B36B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 09:48:25 -0400 (EDT)
Date: Thu, 17 Jun 2010 08:45:09 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Slabinfo: Fix display format
In-Reply-To: <20100617155420.GB2693@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1006170844300.22997@router.home>
References: <20100617155420.GB2693@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: wzt.wzt@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010, wzt.wzt@gmail.com wrote:

> @@ -4271,7 +4271,7 @@ static int s_show(struct seq_file *m, void *p)
>  	if (error)
>  		printk(KERN_ERR "slab: cache %s error: %s\n", name, error);
>
> -	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
> +	seq_printf(m, "%-27s %6lu %6lu %6u %4u %4d",
>  		   name, active_objs, num_objs, cachep->buffer_size,
>  		   cachep->num, (1 << cachep->gfporder));
>  	seq_printf(m, " : tunables %4u %4u %4u",

This one may break user space tools that have assumptions about the length
of the field. Or do tools not make that assumption?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
