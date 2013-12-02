Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCE66B0037
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 16:22:40 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so19858787pbb.17
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:22:39 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id qz9si533250pab.17.2013.12.02.13.22.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Dec 2013 13:22:38 -0800 (PST)
Date: Mon, 2 Dec 2013 13:22:35 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: netfilter: active obj WARN when cleaning up
Message-ID: <20131202212235.GA1297@kroah.com>
References: <20131127134015.GA6011@n2100.arm.linux.org.uk>
 <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de>
 <20131127233415.GB19270@kroah.com>
 <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com>
 <20131202164039.GA19937@kroah.com>
 <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com>
 <20131202172615.GA4722@kroah.com>
 <00000142b4aeca89-186fc179-92b8-492f-956c-38a7c196d187-000000@email.amazonses.com>
 <20131202190814.GA2267@kroah.com>
 <00000142b4d4360c-5755af87-b9b0-4847-b5fa-7a9dd13b49c5-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142b4d4360c-5755af87-b9b0-4847-b5fa-7a9dd13b49c5-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 02, 2013 at 07:41:15PM +0000, Christoph Lameter wrote:
> On Mon, 2 Dec 2013, Greg KH wrote:
> 
> > No, the release callback is in the kobj_type, not the kobject itself.
> 
> Ahh... Ok. Patch follows:
> 
> 
> Subject: slub: use sysfs'es release mechanism for kmem_cache
> 
> Sysfs has a release mechanism. Use that to release the
> kmem_cache structure if CONFIG_SYSFS is enabled.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

That looks good, if you fix the indentation issue :)

> 
> Index: linux/include/linux/slub_def.h
> ===================================================================
> --- linux.orig/include/linux/slub_def.h	2013-12-02 13:31:07.395905824 -0600
> +++ linux/include/linux/slub_def.h	2013-12-02 13:31:07.385906101 -0600
> @@ -98,4 +98,8 @@ struct kmem_cache {
>  	struct kmem_cache_node *node[MAX_NUMNODES];
>  };
> 
> +#ifdef CONFIG_SYSFS
> +#define SLAB_SUPPORTS_SYSFS

Why even define this?  Why not just use CONFIG_SYSFS?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
