Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E18A6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 15:06:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so60248596pfj.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 12:06:23 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id ys7si9154444pac.59.2016.09.16.12.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 12:06:22 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id 21so19192787pfy.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 12:06:22 -0700 (PDT)
Date: Fri, 16 Sep 2016 12:06:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/shmem.c: constify anon_ops
In-Reply-To: <1473890528-7009-1-git-send-email-linux@rasmusvillemoes.dk>
Message-ID: <alpine.LSU.2.11.1609161203350.4175@eggly.anvils>
References: <1473890528-7009-1-git-send-email-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Sep 2016, Rasmus Villemoes wrote:

> Every other dentry_operations instance is const, and this one might as
> well be.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Indeed, thanks,

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  mm/shmem.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index fd8b2b5741b1..693ffdc5899a 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -4077,7 +4077,7 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
>  
>  /* common code */
>  
> -static struct dentry_operations anon_ops = {
> +static const struct dentry_operations anon_ops = {
>  	.d_dname = simple_dname
>  };
>  
> -- 
> 2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
