Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 6FD9A6B00BB
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 03:13:49 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3523145lbj.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 00:13:47 -0700 (PDT)
Date: Thu, 12 Jul 2012 10:13:39 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: linux-next: Early crashed kernel on CONFIG_SLOB
In-Reply-To: <alpine.DEB.2.00.1207101830480.5988@router.home>
Message-ID: <alpine.LFD.2.02.1207121013320.2515@tux.localdomain>
References: <20120710111756.GA11351@localhost> <CF1C132D-2873-408A-BCC9-B9F57BE6EDDB@linuxfoundation.org> <alpine.DEB.2.00.1207101830480.5988@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Christoph Lameter <christoph@linuxfoundation.org>, "wfg@linux.intel.com" <wfg@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 10 Jul 2012, Christoph Lameter wrote:
> Here is the patch:
> 
> Subject: slob: Undo slob hunk
> 
> Commit fd3142a59af2012a7c5dc72ec97a4935ff1c5fc6 broke
> slob since a piece of a change for a later patch slipped into
> it.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  mm/slob.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/slob.c
> ===================================================================
> --- linux-2.6.orig/mm/slob.c	2012-07-06 08:38:18.851205889 -0500
> +++ linux-2.6/mm/slob.c	2012-07-06 08:38:47.259205237 -0500
> @@ -516,7 +516,7 @@ struct kmem_cache *kmem_cache_create(con
> 
>  	if (c) {
>  		c->name = name;
> -		c->size = c->object_size;
> +		c->size = size;
>  		if (flags & SLAB_DESTROY_BY_RCU) {
>  			/* leave room for rcu footer at the end of object */
>  			c->size += sizeof(struct slob_rcu);
> 

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
