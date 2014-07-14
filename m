Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 76C0B6B003B
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 15:38:46 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so2502488pad.13
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:38:46 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id mu3si4955010pdb.206.2014.07.14.12.38.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 12:38:45 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so2502469pad.13
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:38:45 -0700 (PDT)
Date: Mon, 14 Jul 2014 12:36:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: trivial code style fix to shmem_statfs
In-Reply-To: <53C38C3A.3090903@gmail.com>
Message-ID: <alpine.LSU.2.11.1407141231370.17582@eggly.anvils>
References: <53C38C3A.3090903@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org

On Mon, 14 Jul 2014, Wang Sheng-Hui wrote:
> 
> Should read the super_block fields, even if current implementation uses
> the same constants.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

I prefer how it is already, more direct, less code.
They are very unlikely to change: if they do, we can update then.

If you're looking for a trivial patch to make in mm/shmem.c,
I suggest removing the unused gfp arg to shmem_add_to_page_cache().

Hugh

> ---
>  mm/shmem.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 1140f49..368523b 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1874,10 +1874,11 @@ out:
> 
>  static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
>  {
> -       struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
> +       struct super_block *sb = dentry->d_sb;
> +       struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
> 
> -       buf->f_type = TMPFS_MAGIC;
> -       buf->f_bsize = PAGE_CACHE_SIZE;
> +       buf->f_type = sb->s_magic;
> +       buf->f_bsize = sb->s_blocksize;
>         buf->f_namelen = NAME_MAX;
>         if (sbinfo->max_blocks) {
>                 buf->f_blocks = sbinfo->max_blocks;
> -- 
> 1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
