Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 779236B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 04:36:47 -0400 (EDT)
Date: Sat, 20 Apr 2013 15:43:16 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 18/18] ext4: Allow punch hole with bigalloc enabled
Message-ID: <20130420134316.GB2461@quack.suse.cz>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-19-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365498867-27782-19-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue 09-04-13 11:14:27, Lukas Czerner wrote:
> In commits 5f95d21fb6f2aaa52830e5b7fb405f6c71d3ab85 and
> 30bc2ec9598a1b156ad75217f2e7d4560efdeeab we've reworked punch_hole
> implementation and there is noting holding us back from using punch hole
> on file system with bigalloc feature enabled.
> 
> This has been tested with fsx and xfstests.
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

									Honza

> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> ---
>  fs/ext4/inode.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 0d452c1..87d6171 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3536,11 +3536,6 @@ int ext4_punch_hole(struct file *file, loff_t offset, loff_t length)
>  	if (!S_ISREG(inode->i_mode))
>  		return -EOPNOTSUPP;
>  
> -	if (EXT4_SB(sb)->s_cluster_ratio > 1) {
> -		/* TODO: Add support for bigalloc file systems */
> -		return -EOPNOTSUPP;
> -	}
> -
>  	trace_ext4_punch_hole(inode, offset, length);
>  
>  	/*
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
