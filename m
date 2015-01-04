Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 845AD6B0032
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 03:18:46 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so26548758pab.14
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 00:18:46 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id nh6si77667279pdb.201.2015.01.04.00.18.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 Jan 2015 00:18:44 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so26639023pab.2
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 00:18:43 -0800 (PST)
Date: Sun, 04 Jan 2015 17:18:38 +0900 (JST)
Message-Id: <20150104.171838.243342727322803372.konishi.ryusuke@lab.ntt.co.jp>
Subject: Re: [PATCH 6/8] nilfs2: set up s_bdi like the generic mount_bdev
 code
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
In-Reply-To: <1419929859-24427-7-git-send-email-hch@lst.de>
References: <1419929859-24427-1-git-send-email-hch@lst.de>
	<1419929859-24427-7-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org

On Tue, 30 Dec 2014 09:57:37 +0100, Christoph Hellwig <hch@lst.de> wrote:
> mapping->backing_dev_info will go away, so don't rely on it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good for me.

Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

> ---
>  fs/nilfs2/super.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
> index 2e5b3ec..3d4bbac 100644
> --- a/fs/nilfs2/super.c
> +++ b/fs/nilfs2/super.c
> @@ -1057,7 +1057,6 @@ nilfs_fill_super(struct super_block *sb, void *data, int silent)
>  {
>  	struct the_nilfs *nilfs;
>  	struct nilfs_root *fsroot;
> -	struct backing_dev_info *bdi;
>  	__u64 cno;
>  	int err;
>  
> @@ -1077,8 +1076,7 @@ nilfs_fill_super(struct super_block *sb, void *data, int silent)
>  	sb->s_time_gran = 1;
>  	sb->s_max_links = NILFS_LINK_MAX;
>  
> -	bdi = sb->s_bdev->bd_inode->i_mapping->backing_dev_info;
> -	sb->s_bdi = bdi ? : &default_backing_dev_info;
> +	sb->s_bdi = &bdev_get_queue(sb->s_bdev)->backing_dev_info;
>  
>  	err = load_nilfs(nilfs, sb);
>  	if (err)
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
