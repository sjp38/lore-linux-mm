Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9948E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:25:33 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id y193so1032894ybe.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:25:33 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i4si1405738ybp.8.2019.01.23.06.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:25:32 -0800 (PST)
Date: Wed, 23 Jan 2019 09:25:07 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] mm: cleancache: no need to check return value of
 debugfs_create functions
Message-ID: <20190123142504.GA19985@Konrads-MacBook-Pro.local>
References: <20190122152151.16139-12-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122152151.16139-12-gregkh@linuxfoundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 22, 2019 at 04:21:11PM +0100, Greg Kroah-Hartman wrote:
> When calling debugfs functions, there is no need to ever check the
> return value.  The function can work or not, but the code logic should
> never do something different based on this.
> 
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

OK.

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

or I can push it through my tree but it may be just easier for Andrew
too do it
> Cc: linux-mm@kvack.org
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
>  mm/cleancache.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/cleancache.c b/mm/cleancache.c
> index 2bf12da9baa0..082fdda7aaa6 100644
> --- a/mm/cleancache.c
> +++ b/mm/cleancache.c
> @@ -305,8 +305,7 @@ static int __init init_cleancache(void)
>  {
>  #ifdef CONFIG_DEBUG_FS
>  	struct dentry *root = debugfs_create_dir("cleancache", NULL);
> -	if (root == NULL)
> -		return -ENXIO;
> +
>  	debugfs_create_u64("succ_gets", 0444, root, &cleancache_succ_gets);
>  	debugfs_create_u64("failed_gets", 0444, root, &cleancache_failed_gets);
>  	debugfs_create_u64("puts", 0444, root, &cleancache_puts);
> -- 
> 2.20.1
> 
