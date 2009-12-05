Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 007646B0044
	for <linux-mm@kvack.org>; Sat,  5 Dec 2009 15:30:31 -0500 (EST)
Date: Sat, 5 Dec 2009 20:30:21 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC PATCH 12/15] ima-path-check rework
In-Reply-To: <20091204204816.18286.15738.stgit@paris.rdu.redhat.com>
Message-ID: <Pine.LNX.4.64.0912052026440.6368@sister.anvils>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
 <20091204204816.18286.15738.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009, Eric Paris wrote:

I've not checked through this whole patch and your whole patchset,
but certainly when IMA came in, I felt (and said) that these calls
should be done at a lower level, so as not to affect each filesystem.
So I thoroughly approve of the direction of your patchset, even
though I cannot vouch for the details of it.  Thank you, Eric.

Hugh

> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -29,7 +29,6 @@
>  #include <linux/mm.h>
>  #include <linux/module.h>
>  #include <linux/swap.h>
> -#include <linux/ima.h>
>  
>  static struct vfsmount *shm_mnt;
>  
> @@ -2655,8 +2654,6 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
>  	if (!file)
>  		goto put_dentry;
>  
> -	ima_counts_get(file);
> -
>  #ifndef CONFIG_MMU
>  	error = ramfs_nommu_expand_for_mapping(inode, size);
>  	if (error) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
