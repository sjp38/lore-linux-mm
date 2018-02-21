Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2BC86B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 05:22:39 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w102so1007741wrb.21
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 02:22:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c64si4602210wme.212.2018.02.21.02.22.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 02:22:38 -0800 (PST)
Date: Wed, 21 Feb 2018 11:22:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: zsmalloc: Replace return type int with bool
Message-ID: <20180221102237.GB14384@dhcp22.suse.cz>
References: <20180220175811.GA28277@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180220175811.GA28277@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org

On Tue 20-02-18 23:28:11, Souptick Joarder wrote:
[...]
> -static int zs_register_migration(struct zs_pool *pool)
> +static bool zs_register_migration(struct zs_pool *pool)
>  {
>  	pool->inode = alloc_anon_inode(zsmalloc_mnt->mnt_sb);
>  	if (IS_ERR(pool->inode)) {
>  		pool->inode = NULL;
> -		return 1;
> +		return true;
>  	}
> 
>  	pool->inode->i_mapping->private_data = pool;
>  	pool->inode->i_mapping->a_ops = &zsmalloc_aops;
> -	return 0;
> +	return false;
>  }

Don't you find it a bit strange that the function returns false on
success?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
