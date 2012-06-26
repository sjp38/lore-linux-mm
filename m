Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 9455D6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:36:56 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so362995vcb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:36:55 -0700 (PDT)
Date: Tue, 26 Jun 2012 18:36:51 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH v2 1/9] zcache: fix refcount leak
Message-ID: <20120626223651.GB6561@localhost.localdomain>
References: <4FE97792.9020807@linux.vnet.ibm.com>
 <4FE977AA.2090003@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE977AA.2090003@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

On Tue, Jun 26, 2012 at 04:49:46PM +0800, Xiao Guangrong wrote:
> In zcache_get_pool_by_id, the refcount of zcache_host is not increased, but
> it is always decreased in zcache_put_pool

All of the patches (1-9) look good to me, so please also
affix 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>'.

You also might want to send this patch series with Greg KH being
on the To line- not just as CC -as he is the one committing the
patches in the git tree.

> 
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index c9e08bb..55fbe3d 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -946,8 +946,9 @@ static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id, uint16_t poolid)
>  		cli = &zcache_clients[cli_id];
>  		if (cli == NULL)
>  			goto out;
> -		atomic_inc(&cli->refcount);
>  	}
> +
> +	atomic_inc(&cli->refcount);
>  	pool = idr_find(&cli->tmem_pools, poolid);
>  	if (pool != NULL)
>  		atomic_inc(&pool->refcount);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
