Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id DE4786B0254
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 15:29:17 -0400 (EDT)
Received: by wiar9 with SMTP id r9so79404754wia.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 12:29:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si750784wix.59.2015.07.01.12.29.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 12:29:16 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:29:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 51/51] ext2: enable cgroup writeback support
Message-ID: <20150701192912.GN7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-52-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-52-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, linux-ext4@vger.kernel.org

On Fri 22-05-15 17:14:05, Tejun Heo wrote:
> Writeback now supports cgroup writeback and the generic writeback,
> buffer, libfs, and mpage helpers that ext2 uses are all updated to
> work with cgroup writeback.
> 
> This patch enables cgroup writeback for ext2 by adding
> FS_CGROUP_WRITEBACK to its ->fs_flags.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> Cc: linux-ext4@vger.kernel.org

Hallelujah!

Reviewed-by: Jan Kara <jack@suse.com>

> ---
>  fs/ext2/super.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/ext2/super.c b/fs/ext2/super.c
> index d0e746e..549219d 100644
> --- a/fs/ext2/super.c
> +++ b/fs/ext2/super.c
> @@ -1543,7 +1543,7 @@ static struct file_system_type ext2_fs_type = {
>  	.name		= "ext2",
>  	.mount		= ext2_mount,
>  	.kill_sb	= kill_block_super,
> -	.fs_flags	= FS_REQUIRES_DEV,
> +	.fs_flags	= FS_REQUIRES_DEV | FS_CGROUP_WRITEBACK,
>  };
>  MODULE_ALIAS_FS("ext2");
>  
> -- 
> 2.4.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
