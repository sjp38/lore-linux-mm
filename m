Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFDCA280858
	for <linux-mm@kvack.org>; Wed, 10 May 2017 07:05:01 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 44so7590649wry.5
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:05:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v60si2779414wrc.210.2017.05.10.04.04.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 04:05:00 -0700 (PDT)
Date: Wed, 10 May 2017 13:04:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 01/27] fs: remove unneeded forward definition of
 mm_struct from fs.h
Message-ID: <20170510110457.GA25137@quack2.suse.cz>
References: <20170509154930.29524-1-jlayton@redhat.com>
 <20170509154930.29524-2-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509154930.29524-2-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Tue 09-05-17 11:49:04, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 7251f7bb45e8..38adefd8e2a0 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1252,8 +1252,6 @@ extern void f_delown(struct file *filp);
>  extern pid_t f_getown(struct file *filp);
>  extern int send_sigurg(struct fown_struct *fown);
>  
> -struct mm_struct;
> -
>  /*
>   *	Umount options
>   */
> -- 
> 2.9.3
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
