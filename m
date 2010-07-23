Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 707F96B02AE
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 15:36:54 -0400 (EDT)
Date: Fri, 23 Jul 2010 12:36:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/6] fs: remove dependency on __GFP_NOFAIL
Message-Id: <20100723123618.3b2b8824.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1007201939430.8728@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1007201939430.8728@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jul 2010 19:45:00 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The kmalloc() in bio_integrity_prep() is failable, so remove __GFP_NOFAIL
> from its mask.
> 
> Cc: Jens Axboe <jens.axboe@oracle.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  fs/bio-integrity.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/bio-integrity.c b/fs/bio-integrity.c
> --- a/fs/bio-integrity.c
> +++ b/fs/bio-integrity.c
> @@ -413,7 +413,7 @@ int bio_integrity_prep(struct bio *bio)
>  
>  	/* Allocate kernel buffer for protection data */
>  	len = sectors * blk_integrity_tuple_size(bi);
> -	buf = kmalloc(len, GFP_NOIO | __GFP_NOFAIL | q->bounce_gfp);
> +	buf = kmalloc(len, GFP_NOIO | q->bounce_gfp);
>  	if (unlikely(buf == NULL)) {
>  		printk(KERN_ERR "could not allocate integrity buffer\n");
>  		return -EIO;

                        ^^^  what?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
