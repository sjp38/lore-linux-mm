Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 981466B02F4
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 00:36:43 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r24so31474517ioi.8
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 21:36:43 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o189si2813830itb.21.2017.06.12.21.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 21:36:42 -0700 (PDT)
Date: Mon, 12 Jun 2017 21:30:56 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v6 19/20] xfs: minimal conversion to errseq_t writeback
 error reporting
Message-ID: <20170613043056.GO4530@birch.djwong.org>
References: <20170612122316.13244-1-jlayton@redhat.com>
 <20170612122316.13244-24-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612122316.13244-24-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Mon, Jun 12, 2017 at 08:23:15AM -0400, Jeff Layton wrote:
> Just set the FS_WB_ERRSEQ flag to indicate that we want to use errseq_t
> based error reporting. Internal filemap_* calls are left as-is for now.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/xfs/xfs_super.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index 455a575f101d..28d3be187025 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
> @@ -1758,7 +1758,7 @@ static struct file_system_type xfs_fs_type = {
>  	.name			= "xfs",
>  	.mount			= xfs_fs_mount,
>  	.kill_sb		= kill_block_super,
> -	.fs_flags		= FS_REQUIRES_DEV,
> +	.fs_flags		= FS_REQUIRES_DEV | FS_WB_ERRSEQ,

Huh?  Why are there two patches with the same subject line?  And this
same bit of code too?  Or ... 11/13, 11/20?  What's going on here?

<confused>

--D

>  };
>  MODULE_ALIAS_FS("xfs");
>  
> -- 
> 2.13.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
