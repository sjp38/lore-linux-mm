Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF9846B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 19:55:16 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o1Q0t9AP020141
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:55:09 -0800
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by wpaz13.hot.corp.google.com with ESMTP id o1Q0t704007696
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:55:08 -0800
Received: by pwj7 with SMTP id 7so5311401pwj.14
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:55:07 -0800 (PST)
Date: Thu, 25 Feb 2010 16:55:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] failslab: add ability to filter slab caches [v2]
In-Reply-To: <1267078900-4626-2-git-send-email-dmonakhov@openvz.org>
Message-ID: <alpine.DEB.2.00.1002251652190.5560@chino.kir.corp.google.com>
References: <1267078900-4626-1-git-send-email-dmonakhov@openvz.org> <1267078900-4626-2-git-send-email-dmonakhov@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dmitry Monakhov <dmonakhov@openvz.org>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, akinobu.mita@gmail.com, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Feb 2010, Dmitry Monakhov wrote:

> @@ -1020,6 +1021,11 @@ static int __init setup_slub_debug(char *str)
>  		case 't':
>  			slub_debug |= SLAB_TRACE;
>  			break;
> +#ifdef CONFIG_FAILSLAB
> +		case 'a':
> +			slub_debug |= SLAB_FAILSLAB;
> +			break;
> +#endif
>  		default:
>  			printk(KERN_ERR "slub_debug option '%c' "
>  				"unknown. skipped\n", *str);

The #ifdef is unnecessary, SLAB_FAILSLAB is 0x0 when CONFIG_FAILSLAB isn't 
set.

When that's changed, feel free to add my:

	Acked-by: David Rientjes <rientjes@google.com>

and send an updated version to Pekka Enberg <penberg@cs.helsinki.fi> and 
cc Christoph Lameter <cl@linux-foundation.org>.

I guess 'A' is the best letter to use for `slub_debug' (fAil slab? :) 
since 'F' is already used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
